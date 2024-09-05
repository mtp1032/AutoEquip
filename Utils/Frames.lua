--------------------------------------------------------------------------------------
-- Frames.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.Frames = {}
local frames = AutoEquip.Frames
local dbg = AutoEquip.Debug	-- use for error reporting services
local L = AutoEquip.Locales

local DEFAULT_FRAME_WIDTH   = 600
local DEFAULT_FRAME_HEIGHT  = 400
local TITLE_BAR_WIDTH       = 600
local TITLE_BAR_HEIGHT      = 100

--------------------------------------------------------------------------
--                         CREATE THE VARIOUS BUTTONS
--------------------------------------------------------------------------
local function createResizeButton( f )
	f:SetResizable( true )
	local resizeButton = CreateFrame("Button", nil, f)
	resizeButton:SetSize(16, 16)
	resizeButton:SetPoint("BOTTOMRIGHT")
	resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	resizeButton:SetScript("OnMouseDown", function(self, button)
    	f:StartSizing("BOTTOMRIGHT")
    	f:SetUserPlaced(true)
	end)
 
	resizeButton:SetScript("OnMouseUp", function(self, button)
		f:StopMovingOrSizing()
		frameWidth, frameHeight= f:GetSize()
	end)
end
local function createClearButton( f, placement, offX, offY )
    local clearButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    clearButton:SetPoint(placement, f, 5, 5)
    clearButton:SetHeight(25)
    clearButton:SetWidth(70)
    clearButton:SetText( "Clear")
    clearButton:SetScript("OnClick", 
        function(self)
            self:GetParent().Text:EnableMouse( false )    
            self:GetParent().Text:EnableKeyboard( false )   
            self:GetParent().Text:SetText("") 
            self:GetParent().Text:ClearFocus()
        end)
    f.clearButton = clearButton
end
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
	reloadButton:SetPoint(placement, f, 5, 5) -- was -175, 10
    reloadButton:SetHeight(25)
    reloadButton:SetWidth(70)
    reloadButton:SetText( "UI Reload")
    reloadButton:SetScript("OnClick", 
        function(self)
            ReloadUI()
        end)
    f.reloadButton = reloadButton
end
local function createSelectButton( f, placement, offX, offY )
    local selectButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    selectButton:SetPoint(placement, f, -5, 5)

    selectButton:SetHeight(25)
    selectButton:SetWidth(70)
    selectButton:SetText( "Select" )
    selectButton:SetScript("OnClick", 
        function(self)
            self:GetParent().Text:EnableMouse( true )    
            self:GetParent().Text:EnableKeyboard( true )   
            self:GetParent().Text:HighlightText()
            self:GetParent().Text:SetFocus()
        end)
    f.selectButton = selectButton
end
local function createResetButton( f, placement, offX, offY )
    local resetButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetButton:SetPoint(placement, f, 5, 5)
    resetButton:SetHeight(25)
    resetButton:SetWidth(70)
    resetButton:SetText( "Reset" )
    resetButton:SetScript("OnClick", 
        function(self)
            self:GetParent().Text:EnableMouse( false )    
            self:GetParent().Text:EnableKeyboard( false )   
            self:GetParent().Text:SetText("") 
            self:GetParent().Text:ClearFocus()
           end)
    f.resetButton = resetButton
end
--------------------------------------------------------------------------
--                         CREATE THE FRAMES
--------------------------------------------------------------------------
local FRAME_WIDTH = 600
local FRAME_HEIGHT = 400
local TITLE_BAR_WIDTH = 600
local TITLE_BAR_HEIGHT = 100

local LINE_SEGMENT_LENGTH = 575
local X_START_POINT = 10
local Y_START_POINT = 10

local function drawLine(f, yPos)
    local lineFrame = CreateFrame("FRAME", nil, f)
    -- lineFrame:SetPoint("CENTER", -10, yPos)
    lineFrame:SetPoint("CENTER", 0, yPos)
    lineFrame:SetSize(LINE_SEGMENT_LENGTH, 2)
    
    local line = lineFrame:CreateLine(nil, "ARTWORK")
    line:SetColorTexture(.5, .5, .5, 1) -- Grey per https://wow.gamepedia.com/Power_colors
    line:SetThickness(2)
    line:SetStartPoint("LEFT", 0, 0)
    line:SetEndPoint("RIGHT", 0, 0)
    lineFrame:Show()
end

local function createTextDisplay(f)
    f.ScrollFrame = CreateFrame("ScrollFrame", "$parent_DF", f, "UIPanelScrollFrameTemplate")
    f.ScrollFrame:SetPoint("TOPLEFT", f, 12, -30)
    f.ScrollFrame:SetPoint("BOTTOMRIGHT", f, -30, 40)

    --                  Now create the EditBox
    f.Text = CreateFrame("EditBox", nil, f)
    f.Text:SetMultiLine(true)
    f.Text:SetSize(DEFAULT_FRAME_WIDTH - 20, DEFAULT_FRAME_HEIGHT )
    f.Text:SetPoint("TOPLEFT", f.ScrollFrame)    -- ORIGINALLY TOPLEFT
    f.Text:SetPoint("BOTTOMRIGHT", f.ScrollFrame) -- ORIGINALLY BOTTOMRIGHT
    f.Text:SetMaxLetters(99999)
    f.Text:SetFontObject(GameFontNormal) -- Color this R 99, G 14, B 55
    f.Text:SetHyperlinksEnabled( true )
    f.Text:SetTextInsets(5, 5, 5, 5, 5)
    f.Text:SetAutoFocus(false)
    f.Text:EnableMouse( false )
    f.Text:EnableKeyboard( false )
    f.Text:SetScript("OnEscapePressed", 
        function(self) 
            self:ClearFocus() 
        end) 
    f.ScrollFrame:SetScrollChild(f.Text)
end

local function createTextFrame( frameTitle )
    local f = CreateFrame("Frame", "MsgFrame", UIParent, "BackdropTemplate")
    f:SetFrameStrata("HIGH")
    f:SetPoint("CENTER", 0, 100)

    f:SetSize(DEFAULT_FRAME_WIDTH, DEFAULT_FRAME_HEIGHT)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    -- Set the backdrop for the main frame
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.7)
    
    -- Create the title bar
    f.titleBar = f:CreateTexture(nil, "ARTWORK")
    f.titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    f.titleBar:SetPoint("TOP", f, "TOP", 0, 25)  -- Positioned slightly above the frame to overlap
    f.titleBar:SetSize(TITLE_BAR_WIDTH, TITLE_BAR_HEIGHT)

    -- Create the title text
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFontObject("GameFontHighlight")
    f.title:SetPoint("CENTER", f.titleBar, "CENTER", 0, 22)  -- Centered within the title bar
    f.title:SetTextColor(1, 1, 0)  -- Yellow color (R, G, B)
	f.title:SetText( frameTitle )

    createTextDisplay(f)

    createResizeButton(f)
    createSelectButton(f, "BOTTOMRIGHT",f, 5, 5)
    createDismissButton(f, "BOTTOMLEFT",f, 5, 5)
    return f

end

--------------------------------------------------------------------------
--                   THESE ARE THE PUBLIC FRAMES
--------------------------------------------------------------------------
function frames:createMsgFrame( frameTitle )
    local f = createTextFrame( frameTitle )
    return f
end

function frames:createHelpFrame( frameTitle )
    local f = CreateFrame("Frame", "MsgFrame", UIParent, "BackdropTemplate")
    f:SetFrameStrata("HIGH")
    f:SetPoint("CENTER", 0, 100)

    f:SetSize(DEFAULT_FRAME_WIDTH, DEFAULT_FRAME_HEIGHT)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    -- Set the backdrop for the main frame
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.7)
    
    -- Create the title bar
    f.titleBar = f:CreateTexture(nil, "ARTWORK")
    f.titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    f.titleBar:SetPoint("TOP", f, "TOP", 0, 25)  -- Positioned slightly above the frame to overlap
    f.titleBar:SetSize(TITLE_BAR_WIDTH, TITLE_BAR_HEIGHT)

    -- Create the title text
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFontObject("GameFontHighlight")
    f.title:SetPoint("CENTER", f.titleBar, "CENTER", 0, 22)  -- Centered within the title bar
    f.title:SetTextColor(1, 1, 0)  -- Yellow color (R, G, B)
	f.title:SetText( frameTitle )

    -- createTextDisplay(f)
    local helpStr = string.format("Slash Commands\n" )
    local titleHelpStr = nil
    titleHelpStr = f:CreateFontString( nil, "ARTWORK","GameFontNormalLarge" )
    titleHelpStr:SetJustifyH("LEFT")
    titleHelpStr:SetPoint("CENTER", 0, DEFAULT_FRAME_HEIGHT/4 )
    titleHelpStr:SetText( helpStr )

    local usage = string.format("USAGE:\n")
    local line1 = string.format("    /auto         - displays this help window.")
	local line2 = string.format("    /auto help    - displays this help window\n")
    local line3 = string.format("Debug Tracing?")
	local line4 = string.format("    /auto debug enable|disable.")

	local bodyText = f:CreateFontString(nil, "ARTWORK","GameFontNormal")
	bodyText:SetJustifyH("LEFT")
	bodyText:SetPoint("CENTER", 0, 0 )
	bodyText:SetText(string.format("%s\n%s\n%s\n%s\n%s", usage, line1, line2, line3, line4 ))

    createDismissButton(f, "BOTTOMLEFT",f, 5, 5)

    return f
end


local fileName = "Frames.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("[%s] %s loaded.", ADDON_NAME,fileName ), 1,1,1 )
end

