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
local function createDefaultsButton(f, width, height) -- creates Default button

	f.hide = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.hide:SetText("Defaults")
	f.hide:SetHeight(height)	-- original value 20
	f.hide:SetWidth(width)		-- original value 80
	f.hide:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 8, 8)
	f.hide:SetScript("OnClick",
		function( self )
			DEFAULT_CHAT_FRAME:AddMessage( sprintf("<Not Yet Implemented>", set ), 1.0, 1.0, 0.0 )
			optionsPanel:Hide()
		end)
end
local function createAcceptButton(f, width, height) -- creates Accept button
    -- -- Accept buttom, bottom right
	f.hide = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.hide:SetText("Accept")
	f.hide:SetHeight(height)	-- Original value = 20
	f.hide:SetWidth(width)		-- Original value = 80
	f.hide:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
	f.hide:SetScript("OnClick",
		function( self )
			DEFAULT_CHAT_FRAME:AddMessage( sprintf("<Not Yet Implemented>", set ), 1.0, 1.0, 0.0 )
			optionsPanel:Hide()
		end)
end

---- INPUT DIALOG BOX
local function createInputDialogBox(frame, title, XPOS, YPOS) -- creates the input Dialog box
	title = sprintf("Enter the name of the armor set to be equipped when\n")
	title = title .. sprintf("entering a rest area (UI Will Be Reloaded)") 
	local str = string.upper( title )
	local DescrSubHeader = frame:CreateFontString(nil, "ARTWORK","GameFontNormal")
    DescrSubHeader:SetPoint("LEFT", XPOS, YPOS + 40)
	DescrSubHeader:SetText( title )
	DescrSubHeader:SetJustifyH("LEFT")

	local f = CreateFrame("EditBox", "InputEditBox", frame, "InputBoxTemplate")
	f:SetFrameStrata("DIALOG")
	f:SetSize(200,75)
	f:SetAutoFocus(false)
	f:SetPoint("LEFT", XPOS, YPOS)
	f:SetText( "" )
	f:SetScript("OnEnterPressed", 
		function(self,button)
			local result = {SUCCESS, EMPTY_STR, EMPTY_STR }
			local equipSetName = f:GetText()
			result = equip:setRestXpSet( equipSetName )
			if not result[1] then msgf:postResult( result ) 
			end
			ClearCursor()
			f:SetText("")
			optionsPanel:Hide()
	end)
end
-- Option Menu Settings
local FRAME_WIDTH 		= 600
local FRAME_HEIGHT 		= 400
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

	createAcceptButton(frame, buttonWidth, buttonHeight)
	createDefaultsButton(frame, buttonWidth, buttonHeight)

	-------------------- INTRO HEADER -----------------------------------------
	-- local subTitle = frame:CreateFontString(nil, "ARTWORK","GameFontNormal")
	-- local msgText = frame:CreateFontString(nil, "ARTWORK","GameFontNormalLarge")

	-- local displayString = "Options"
	-- msgText:SetPoint("TOP", 0, -30)
	-- msgText:SetText(displayString)

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
	drawLine( 50, frame )
	-- coords for line
	local xPos = 20
	local yPos = -250
	local yOffset = -20

	xPos = 40
	yPos = yPos + yOffset

	-- create and display the input dialog box for specifying the dummy target's health
	acceptButton = createInputDialogBox(frame, 
										info,
										20, 
										-100)

	frame:Show() 
	return frame   
end
optionsPanel = createOptionsPanel()
function menu:isVisible()
	return optionsPanel:IsVisible()
end
function menu:show()
	if not optionsPanel:IsVisible() then
		optionsPanel:Show()
	end
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

