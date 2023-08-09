--------------------------------------------------------------------------------------
-- OptionsMenu
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local _, AutoEquip = ...
AutoEquip.OptionsMenu = {}
menu = AutoEquip.OptionsMenu

local L = AutoEquip.L

local dbg = equipdbg

local sprintf = _G.string.format
local EMPTY_STR = dbg.EMPTY_STR
local SUCCESS = dbg.SUCCESS

--[[ 
GameFontNormal
GameFontNormalSmall
GameFontNormalLarge
GameFontHighlight
GameFontHighlightSmall
GameFontHighlightSmallOutline
GameFontHighlightLarge
GameFontDisable
GameFontDisableSmall
GameFontDisableLarge
GameFontGreen
GameFontGreenSmall
GameFontGreenLarge
GameFontRed
GameFontRedSmall
GameFontRedLarge
GameFontWhite
GameFontDarkGraySmall
NumberFontNormalYellow
NumberFontNormalSmallGray
QuestFontNormalSmall
DialogButtonHighlightText
ErrorFont
TextStatusBarText
CombatLogFont	
 ]]
------------------------------------------------------------
--						SAVED GLOBALS
------------------------------------------------------------
local optionsPanel = nil

local LINE_SEGMENT_LENGTH 	= 575
local X_START_POINT 		= 10
local Y_START_POINT 		= X_START_POINT

local function drawLine( yPos, f)
	local lineFrame = CreateFrame("FRAME", nil, f )
	lineFrame:SetPoint("CENTER", -10, yPos )
	lineFrame:SetSize(LINE_SEGMENT_LENGTH, LINE_SEGMENT_LENGTH)
	
	local line = lineFrame:CreateLine(1)
	line:SetColorTexture(.5, .5, .5, 1) -- Grey per https://wow.gamepedia.com/Power_colors
	line:SetThickness(2)
	line:SetStartPoint("LEFT",X_START_POINT, Y_START_POINT)
	line:SetEndPoint("RIGHT", X_START_POINT, Y_START_POINT)
	lineFrame:Show() 
end

---- INPUT ARMOR SET ICONS
local function createArmorSetIcon( f, setName, iconFileId, i )
	local BUTTON_WIDTH  = 48
	local BUTTON_HEIGHT = 48

	local btn = CreateFrame("Button",nil, f,"TooltipBackdropTemplate")
	btn.isComplete = true
	btn:SetSize( BUTTON_WIDTH, BUTTON_HEIGHT )
	btn:SetPoint( "LEFT", (BUTTON_WIDTH + 10) * (i + 2) + 20, -50 )

	-- button:SetPoint("TOPLEFT",5,-((i-1)*BUTTON_HEIGHT)-24)	-- from Visual Thread

	btn.Name = btn:CreateFontString(nil,"ARTWORK", "GameFontNormalSmall")
	btn.Name:SetPoint("BOTTOM", 0, 4 )
	btn.Name:SetText( setName )

	btn.Texture = btn:CreateTexture(nil,"ARTWORK")
	btn.Texture:SetPoint("TOPLEFT",3,-3)
	btn.Texture:SetPoint("BOTTOMRIGHT",-3,3)
	btn.Texture:SetTexCoord(0.075,0.925,0.075,0.925) -- trim off icon's edges
	btn:SetNormalTexture(iconFileId)
	btn:SetHighlightTexture(iconFileId )
	btn:GetHighlightTexture():SetAlpha(0.8)

	btn.Mask = btn:CreateMaskTexture(nil,"ARTWORK")
	btn.Mask:SetPoint("TOPLEFT",btn.Texture,"TOPLEFT")
	btn.Mask:SetPoint("BOTTOMRIGHT",btn.Texture,"BOTTOMRIGHT")
	btn.Mask:SetTexture("Interface\\Common\\common-iconmask.blp")
	btn.Texture:AddMaskTexture(btn.Mask)

	btn:RegisterForClicks("AnyDown")
	btn:SetScript("OnClick", 
	function ( self )
		local result = {SUCCESS, EMPTY_STR, EMPTY_STR }

		local equipSetName = btn.Name:GetText()
		local result = equip:setRestXpSet( equipSetName )
		if not result[1] then
			msgf:postResult( result )
			return
		end
		optionsPanel:Hide()
		C_UI.Reload()
	end)
	return btn
end
-- -- Option Menu Settings
local FRAME_WIDTH 		= 600
local FRAME_HEIGHT 		= 300
local TITLE_BAR_WIDTH 	= 600
-- local TITLE_BAR_HEIGHT 	= 45
local TITLE_BAR_HEIGHT 	= 75

local function createOptionsPanel()
	if optionsPanel ~= nil then
		return optionsPanel
	end

	local frame = CreateFrame("Frame", "AutoEquip Settings", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	frame:SetFrameStrata("HIGH")
	frame:SetToplevel(true)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
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
	frame.titleBar:SetPoint( "TOP", 0, 20 )
    frame.titleBar:SetSize( TITLE_BAR_WIDTH, TITLE_BAR_HEIGHT )

	-- frame.title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	frame.title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	frame.title:SetPoint("TOP", 0, 4)
	frame.title:SetText( "AutoEquip (V 1.0.0)")

	-- frame.title:SetText("AUTO_EQUIP Options")

    -- Title text
	frame.text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	frame.text:SetPoint("TOPLEFT", 12, -22)
	frame.text:SetWidth(frame:GetWidth() - 20)
	frame.text:SetJustifyH("LEFT")
	frame:SetHeight(frame.text:GetHeight() + 70)
	tinsert( UISpecialFrames, frame:GetName() ) 
    frame:SetSize( FRAME_WIDTH, FRAME_HEIGHT )
	local buttonWidth = 80
	local buttonHeight	= 20

	frame.btn = {}
	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	local iconFileID = nil
	local armorSetIcon = nil

	for i = 1, #setIDs do
		local setName, iconFileId,setId,_, numItems, numEquipped, numInInventory = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if numItems == numEquipped + numInInventory then
			iconFileID = iconFileId
		else
			iconFileID = 134400
			msgf:postMsg( sprintf("The %s set is missing one or more items\n", setName ))
			armorSetIcon = createArmorSetIcon ( frame, setName, iconFileID, i )
			armorSetIcon.IsComplete = false
		end
		frame.btn[i] = createArmorSetIcon ( frame, setName, iconFileID, i )
	end
    -------------------- DESCRIPTION ---------------------------------------
    local DescrSubHeader = frame:CreateFontString(nil, "ARTWORK","GameFontNormal")
	local messageText = frame:CreateFontString(nil, "ARTWORK","GameFontNormal")
	messageText:SetJustifyH("LEFT")

	local summary = sprintf("AutoEquip is used to automatically and transparently equip\n")
	summary = summary .. sprintf("a specific armor set when entering a rest area. Usually\n")
	summary = summary .. sprintf("this means an armor set containing one or more Heirloom\n")
	summary = summary .. sprintf("items.\n")
	messageText:SetJustifyH("LEFT")
	messageText:SetPoint("TOP", 0, -50)
	messageText:SetText( summary )

	-- drawLine( 220, frame )
	drawLine( 0, frame )
	local equippedSet = equip:getEquippedSet()
	if equippedSet == nil then
		msgf:postMsg( sprintf("No usable equipment sets available. Usually this error\noccurs when one or more items are missing\n"))
		equippedSet = "N/A"
	end
	local msgText = sprintf("Currently Equipped: %s\n", equippedSet )
	local equippedSet = frame:CreateFontString(nil, "ARTWORK","GameFontNormal")
	equippedSet:SetPoint("LEFT", 120, -100)
	equippedSet:SetText( msgText )
	equippedSet:SetJustifyH("LEFT")
	
	frame:Show() 
	return frame   
end
function menu:show()
	if optionsPanel == nil then
		optionsPanel = createOptionsPanel()
	end
	optionsPanel:Show()
end
function menu:hide()
	if optionsPanel:IsVisible() then
		optionsPanel:Hide()
	end
end

local fileName = "OptionsMenu.lua"
if dbg:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end

