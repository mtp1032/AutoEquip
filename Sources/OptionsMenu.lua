--------------------------------------------------------------------------------------
-- OptionsMenu
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.OptionsMenu = {}
local menu  = AutoEquip.OptionsMenu
local auto  = AutoEquip.AutoEquip
local dbg   = AutoEquip.Debug	-- use for error reporting services
local mf    = AutoEquip.MsgFrame

local L = AutoEquip.Locales
local EMPTY_STR = ""
local SUCCESS = true
local FAILURE = false
local equipSetName = nil


------------------------------------------------------------
--						SAVED GLOBALS
------------------------------------------------------------

-- Option Menu Settings

local optionsPanel = nil
local FRAME_WIDTH 		= 600
local FRAME_HEIGHT 		= 400
local TITLE_BAR_WIDTH 	= 600
local TITLE_BAR_HEIGHT 	= 100
local BUTTON_WIDTH  	= 80
local BUTTON_HEIGHT 	= BUTTON_WIDTH
local BUTTON_SPACING	= 10

local LINE_SEGMENT_LENGTH 	= 575
local X_START_POINT 		= 10
local Y_START_POINT 		= X_START_POINT

local armorSetName = nil
local function setArmorSetSelection( selection )
    armorSetName = selection
end
local function createReloadButton( f, placement, offX, offY )
    local reloadButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	reloadButton:SetPoint(placement, f, offX, offY )-- was -175, 10
    reloadButton:SetHeight(25)
    reloadButton:SetWidth(70)
    reloadButton:SetText( "UI Reload")
    reloadButton:SetScript("OnClick", 
        function(self)
            ReloadUI()
        end)
    f.reloadButton = reloadButton
end
local function createDismissButton(f, offX, offY)
    local dismissButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    dismissButton:SetPoint("BOTTOMRIGHT", f, offX, offY)
    dismissButton:SetHeight(25)
    dismissButton:SetWidth(70)
    dismissButton:SetText("Dismiss")
    dismissButton:SetScript("OnClick", 
        function(self)
            dismissButton:GetParent():Hide()
        end)
    f.dismissButton = dismissButton
end
local function createAcceptButton(f, offX, offY)
    local acceptButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    acceptButton:SetPoint("BOTTOMLEFT", f, offX, offY) -- Ensure valid placement
    acceptButton:SetHeight(25)
    acceptButton:SetWidth(70)
    acceptButton:SetText("Accept")

    acceptButton:SetScript("OnClick", function()
        local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
        result = auto:setRestXpSet( equipSetName)
        acceptButton:GetParent():Hide()
        if not result[1] then 
            mf:postResult( result )
        end
    end)

    f.acceptButton = acceptButton
end


local function drawLine(yPos, f)
	local lineFrame = CreateFrame("FRAME", nil, f)
	lineFrame:SetPoint("CENTER", -10, yPos)
	lineFrame:SetSize(LINE_SEGMENT_LENGTH, 2)
	
	local line = lineFrame:CreateLine(nil, "ARTWORK")
	line:SetColorTexture(.5, .5, .5, 1)
	line:SetThickness(2)
	line:SetStartPoint("LEFT", X_START_POINT, 0)
	line:SetEndPoint("RIGHT", X_START_POINT, 0)
	lineFrame:Show()
end


---- INPUT ARMOR SET ICONS
-- local function createArmorSetIcon(f, setName, iconFileId, setId, i )
-- 	-- f is frame.ButtonEnclosure. So, the button is a child of frame.ButtonEnclosure
-- 	local button = CreateFrame("Button", nil, f, "TooltipBackdropTemplate")
-- 	button.isComplete = true
-- 	button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
-- 	button:SetPoint("LEFT", (BUTTON_WIDTH + 10) * (i + 2) + 20, -50)

-- 	button.Name = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
-- 	button.Name:SetPoint("BOTTOM", 0, 4)
-- 	local setName = string.format("%s", setName )
-- 	button.Name:SetText(setName)

-- 	button.Texture = button:CreateTexture(nil, "ARTWORK")
-- 	button.Texture:SetPoint("TOPLEFT", 3, -3)
-- 	button.Texture:SetPoint("BOTTOMRIGHT", -3, 3)
-- 	button.Texture:SetTexCoord(0.075, 0.925, 0.075, 0.925)
-- 	button:SetNormalTexture(iconFileId)
-- 	button:SetHighlightTexture(iconFileId)
-- 	button:GetHighlightTexture():SetAlpha(0.8)

-- 	button.Mask = button:CreateMaskTexture(nil, "ARTWORK")
-- 	button.Mask:SetPoint("TOPLEFT", button.Texture, "TOPLEFT")
-- 	button.Mask:SetPoint("BOTTOMRIGHT", button.Texture, "BOTTOMRIGHT")
-- 	button.Mask:SetTexture("Interface\\Common\\common-iconmask.blp")
-- 	button.Texture:AddMaskTexture(button.Mask)

-- 	button:RegisterForClicks("AnyDown")
-- 	button:SetScript("OnClick", function(self)
-- 		local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
-- 		equipSetName = button.Name:GetText()
--         -- Desaturate the texture to visually indicate the selection
-- 	    if button.Texture then
-- 		    button.Texture:SetDesaturated(true)
-- 	    end
-- 	end)

-- 	return button
-- end
local function createArmorSetIcon(f, setName, iconFileId, setId, i)
	-- f is frame.ButtonEnclosure. So, the button is a child of frame.ButtonEnclosure
	local button = CreateFrame("Button", nil, f, "TooltipBackdropTemplate")
	button.isComplete = true
	button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
	button:SetPoint("LEFT", (BUTTON_WIDTH + 10) * (i + 2) + 20, -50)

	-- Set up the name text
	button.Name = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	button.Name:SetPoint("BOTTOM", 0, 4)
	button.Name:SetText(setName)

	-- Set up the texture (icon)
	button.Texture = button:CreateTexture(nil, "ARTWORK")
	button.Texture:SetPoint("TOPLEFT", 3, -3)
	button.Texture:SetPoint("BOTTOMRIGHT", -3, 3)
	button.Texture:SetTexCoord(0.075, 0.925, 0.075, 0.925)
	button.Texture:SetTexture(iconFileId)  -- Use SetTexture instead of SetNormalTexture

	-- Apply mask to the texture
	button.Mask = button:CreateMaskTexture(nil, "ARTWORK")
	button.Mask:SetPoint("TOPLEFT", button.Texture, "TOPLEFT")
	button.Mask:SetPoint("BOTTOMRIGHT", button.Texture, "BOTTOMRIGHT")
	button.Mask:SetTexture("Interface\\Common\\common-iconmask.blp")
	button.Texture:AddMaskTexture(button.Mask)

	-- Use a custom highlight overlay rather than SetHighlightTexture
	button.Highlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.Highlight:SetTexture(iconFileId)
	button.Highlight:SetAllPoints(button.Texture)
	button.Highlight:SetAlpha(0.8)

	-- Handle the OnClick event
	button:RegisterForClicks("AnyDown")
	button:SetScript("OnClick", 
        function(self)
		    equipSetName = button.Name:GetText()

		    -- Desaturate the texture and persist the desaturation
		    if button.Texture then
			    button.Texture:SetDesaturated(true)  -- This now persists
		    end
	end)

	return button
end

local function processIcons( frame )

    local icons = C_EquipmentSet.GetEquipmentSetIDs()

    -- Calculate ButtonEnclosure width based on the number of icons and spacing
    local buttonEnclosureWidth = (BUTTON_WIDTH * #icons) + (BUTTON_SPACING * (#icons - 1))
    frame.ButtonEnclosure:SetSize(buttonEnclosureWidth, BUTTON_HEIGHT)

    
    -- Center the ButtonEnclosure within 'frame'
    frame.ButtonEnclosure:SetPoint("CENTER", frame, "CENTER", 0, -50 )

    -- Position each icon within the ButtonEnclosure
    
    for i = 1, #icons do
        local setName, iconFileId, setId = C_EquipmentSet.GetEquipmentSetInfo(icons[i])
        local armorSetIcon = createArmorSetIcon(frame.ButtonEnclosure, setName, iconFileId, setId, i)

        -- Calculate the horizontal position of each icon within the ButtonEnclosure
        local iconXPos = (i - 1) * (BUTTON_WIDTH + BUTTON_SPACING)
        armorSetIcon:SetPoint("LEFT", frame.ButtonEnclosure, "LEFT", iconXPos, 0)

        frame.ButtonEnclosure[i] = armorSetIcon
    end
end

-- ChatGPT's solution
local function createOptionsPanel()
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

    local frame = CreateFrame("Frame", "AutoEquipSettings", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 26,
        insets = {left = 9, right = 9, top = 9, bottom = 9},
    })
    frame:SetBackdropColor(0.0, 0.0, 0.0, 0.50)

    frame.titleBar = frame:CreateTexture(nil, "ARTWORK")
    frame.titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    frame.titleBar:SetPoint("TOP", 0, 30) -- was 20
    frame.titleBar:SetSize(TITLE_BAR_WIDTH, TITLE_BAR_HEIGHT)

    frame.title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.title:SetPoint("TOP", 0, 10 )
    local title = string.format("Options Menu\n(%s)", L["ADDON_AND_VERSION"])
    frame.title:SetText( title )

    frame.text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    frame.text:SetPoint("TOPLEFT", 12, -22)
    frame.text:SetWidth(frame:GetWidth() - 20)
    frame.text:SetJustifyH("LEFT")
    frame.equippedSetStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.equippedSetStr:SetPoint("CENTER", 0, -FRAME_HEIGHT/4 )
    frame.equippedSetStr:SetJustifyH("CENTER")

    tinsert(UISpecialFrames, frame:GetName())

    -- Create a ButtonEnclosure to hold the icons
    frame.ButtonEnclosure = CreateFrame("Frame", nil, frame)

    local icons = auto:getAllArmorSetIds()
    -- -- dbg:print( "Sets", #icons)
    -- if #icons == 0 then
    --     local reason = string.format(L["NO_EQUIPMENT_SETS_DEFINED"], UnitName("Player"))
    --     result = dbg:setResult(reason, dbg:prefix())
    --     return frame, result
    -- end
    
    local numIcons = #icons
    -- print( dbg:prefix(), numIcons, #icons )
    if numIcons == 0 then
        -- Schedule the check after a delay
        C_Timer.After(0.5, function()
            processIcons( frame ) -- Call the callback with the updated number of icons
            -- print( dbg:prefix(), "In C_Timer(). Num icons", numIcons )
        end)
    else
        -- If numIcons is not zero, process immediately
        processIcons( frame )
        -- print( dbg:prefix(), "Outside C_Timer(). Num icons", numIcons )

    end
    -- print( dbg:prefix(), numIcons, #icons )

    -- Description and other elements
    local DescrSubHeader = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    local messageText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    messageText:SetJustifyH("LEFT")
    messageText:SetPoint("TOP", 0, -50)
    local optionsText = L["OPTIONS_TEXT_LINE1"] .. L["OPTIONS_TEXT_LINE2"] .. L["OPTIONS_TEXT_LINE3"] ..  L["OPTIONS_TEXT_LINE4"] ..  L["OPTIONS_TEXT_LINE5"]
    messageText:SetText(optionsText)

    drawLine(0, frame)
    createDismissButton(frame, -8, 8)
    createAcceptButton( frame,  5, 5)
    return frame, result
end

local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
optionsPanel, result = createOptionsPanel()
if not result[1] then
    mf:postResult( result )
    return
end

function menu:show()
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

	local equippedSetName = auto:getEquippedSetName()
    if equippedSetName == nil then
		local errorMsg = string.format("%s has not equipped a set.", UnitName("Player"))
		local result = dbg:setResult( errorMsg, dbg:prefix() )
		return result
	end

	optionsPanel.equippedSetStr:SetText( string.format(L["CURRENT_EQUIPPED_SET"], equippedSetName ) )
	optionsPanel:Show()
	local point, relativeTo, relativePoint, xOfs, yOfs = optionsPanel:GetPoint()
	optionsPanel:SetFrameStrata("FULLSCREEN_DIALOG")
    return result
end

local fileName = "OptionsMenu.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("[%s] %s loaded.", ADDON_NAME,fileName ), 1,1,1 )
end
