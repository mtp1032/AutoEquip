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

------------------------------------------------------------
--						SAVED GLOBALS
------------------------------------------------------------

-- Option Menu Settings
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

local function createDismissButton( f, placement, offX, offY )
    local DismissButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    DismissButton:SetPoint(placement, f, 5, 5)
    DismissButton:SetHeight(25)
    DismissButton:SetWidth(70)
    DismissButton:SetText( "Dismiss")
    DismissButton:SetScript("OnClick", 
        function(self)
            -- self:GetParent().Text:EnableMouse( false )    
            -- self:GetParent().Text:EnableKeyboard( false )   
            -- self:GetParent().Text:SetText("") 
            -- self:GetParent().Text:ClearFocus()
            self:GetParent():Hide()
        end)
    f.DismissButton = DismissButton
    
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
-- createDismissButton(f, "BOTTOMLEFT",f, 5, 5
local function createDismissButton(f, placement, offX, offY)
    local DismissButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    DismissButton:SetPoint(placement, f, offX, offY)
    DismissButton:SetHeight(25)
    DismissButton:SetWidth(70)
    DismissButton:SetText("Dismiss")
    DismissButton:SetScript("OnClick", 
        function(self)
            self:GetParent():Hide()
        end)
    f.DismissButton = DismissButton
end

---- INPUT ARMOR SET ICONS
local function createArmorSetIcon(f, setName, iconFileId, setId, i )
	-- f is frame.ButtonEnclosure. So, the button is a child of frame.ButtonEnclosure
	local button = CreateFrame("Button", nil, f, "TooltipBackdropTemplate")
	button.isComplete = true
	button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
	button:SetPoint("LEFT", (BUTTON_WIDTH + 10) * (i + 2) + 20, -50)

	button.Name = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	button.Name:SetPoint("BOTTOM", 0, 4)
	local setName = string.format("%s", setName )
	button.Name:SetText(setName)

	button.Texture = button:CreateTexture(nil, "ARTWORK")
	button.Texture:SetPoint("TOPLEFT", 3, -3)
	button.Texture:SetPoint("BOTTOMRIGHT", -3, 3)
	button.Texture:SetTexCoord(0.075, 0.925, 0.075, 0.925)
	button:SetNormalTexture(iconFileId)
	button:SetHighlightTexture(iconFileId)
	button:GetHighlightTexture():SetAlpha(0.8)

	button.Mask = button:CreateMaskTexture(nil, "ARTWORK")
	button.Mask:SetPoint("TOPLEFT", button.Texture, "TOPLEFT")
	button.Mask:SetPoint("BOTTOMRIGHT", button.Texture, "BOTTOMRIGHT")
	button.Mask:SetTexture("Interface\\Common\\common-iconmask.blp")
	button.Texture:AddMaskTexture(button.Mask)

	button:RegisterForClicks("AnyDown")
	button:SetScript("OnClick", function(self)
		local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
		local equipSetName = button.Name:GetText()
		local result = auto:setRestXpSet(equipSetName)
		if not result[1] then
			mf:postResult( result )
			return
		end
	end)
	return button
end

local function processIcons( frame, setIDs )

    local numIcons = #setIDs

    -- Calculate ButtonEnclosure width based on the number of icons and spacing
    local buttonEnclosureWidth = (BUTTON_WIDTH * numIcons) + (BUTTON_SPACING * (numIcons - 1))
    frame.ButtonEnclosure:SetSize(buttonEnclosureWidth, BUTTON_HEIGHT)

    
    -- Center the ButtonEnclosure within 'frame'
    frame.ButtonEnclosure:SetPoint("CENTER", frame, "CENTER", 0, -50 )

    -- Position each icon within the ButtonEnclosure
    for i = 1, numIcons do
        local setName, iconFileId, setId = C_EquipmentSet.GetEquipmentSetInfo(setIDs[i])
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

    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
    if setIDs == nil then
        local reason = string.format(L["NO_EQUIPMENT_SETS_DEFINED"], UnitName("Player"))
        result = dbg:setResult(reason, dbg:prefix())
        return result
    end
    
    local numIcons = #setIDs
    
    if numIcons == 0 then
        -- Schedule the check after a delay
        C_Timer.After(0.5, function()
            setIDs = C_EquipmentSet.GetEquipmentSetIDs()
            processIcons( frame, setIDs ) -- Call the callback with the updated number of icons
        end)
    else
        -- If numIcons is not zero, process immediately
        processIcons( frame, setIDs )
    end

    -- Description and other elements
    local DescrSubHeader = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    local messageText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    messageText:SetJustifyH("LEFT")
    messageText:SetPoint("TOP", 0, -50)
    local optionsText = L["OPTIONS_TEXT_LINE1"] .. L["OPTIONS_TEXT_LINE2"] .. L["OPTIONS_TEXT_LINE3"] ..  L["OPTIONS_TEXT_LINE4"] ..  L["OPTIONS_TEXT_LINE5"]
    messageText:SetText(optionsText)

    drawLine(0, frame)
    createDismissButton(frame, "BOTTOMRIGHT", -8, 8)
    createReloadButton( frame, "BOTTOMLEFT", 8, 8 )

    frame:Show()
    return frame, result
end

local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
local optionsPanel, result = createOptionsPanel()
if not result[1] then
    mf:postResult( result )
    return
end

auto:setOptionsPanel( optionsPanel)
function menu:show()
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

	local _, equippedSetName, result = auto:getEquippedSet()
	if not result[1] then
		mf:postResult( result )
		return result
	end

	if equippedSetName == nil then
		local errorMsg = string.format( L["NO_EQUIPMENT_SETS_DEFINED"], UnitName("Player") )
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
