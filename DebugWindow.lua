-----------------------------------------------------------------
-- File: DebugWindow.lua
-----------------------------------------------------------------

AutoEquip = AutoEquip or {}
AutoEquip.DebugWindow = AutoEquip.DebugWindow or {}


if not AutoEquip.DebugTools then
    print("DebugTools.lua failed to load")
    return
end

local core  = AutoEquip.Core
local dbg   = AutoEquip.DebugTools
local L     = AutoEquip.enUS.L
local DebugWindow = AutoEquip.DebugWindow

-- Persistent storage
AUTOEQUIP_SAVED_VARS_DB.debugWindow = AUTOEQUIP_SAVED_VARS_DB.debugWindow or {}

local saved = AUTOEQUIP_SAVED_VARS_DB.debugWindow

-- Internal buffer of debug lines
DebugWindow.buffer = {}

-- Forward declarations
local frame, scrollFrame, scrollChild, textArea

-----------------------------------------------------------------
-- Save Position
-----------------------------------------------------------------
function DebugWindow:SavePosition()
    if not frame then return end
    local x, y = frame:GetLeft(), frame:GetTop()
    saved.x, saved.y = x, y
end 

-----------------------------------------------------------------
-- Save Size
-----------------------------------------------------------------
function DebugWindow:SaveSize()
    if not frame then return end
    saved.width  = frame:GetWidth()
    saved.height = frame:GetHeight()
end

-----------------------------------------------------------------
-- Append a line of text to the debug window
-----------------------------------------------------------------
function DebugWindow:Append(msg)
    if not frame then
        self:Create()
    end

    table.insert(self.buffer, msg)

    textArea:SetText(table.concat(self.buffer, "\n"))

    -- Resize scroll child to fit new text
    local height = textArea:GetStringHeight()
    scrollChild:SetHeight(height + 20)

    -- Auto-scroll to bottom
    scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
end

-----------------------------------------------------------------
-- Clear (but keep buffer)
-----------------------------------------------------------------
function DebugWindow:Clear()
    if not frame then return end
    textArea:SetText("")
    scrollChild:SetHeight(20)
end

-----------------------------------------------------------------
-- Reset (delete buffer + clear)
-----------------------------------------------------------------
function DebugWindow:Reset()
    self.buffer = {}
    self:Clear()
end

-----------------------------------------------------------------
-- Get full text for copying
-----------------------------------------------------------------
function DebugWindow:GetText()
    return table.concat(self.buffer, "\n")
end

-----------------------------------------------------------------
-- Show / Hide
-----------------------------------------------------------------
function DebugWindow:Show()
    if not frame then
        self:Create()
    end
    frame:Show()
end

function DebugWindow:Hide()
    if frame then
        frame:Hide()
    end
end

-----------------------------------------------------------------
-- Create the debug window
-----------------------------------------------------------------
function DebugWindow:Create()
    if frame then return end

    -------------------------------------------------------------
    -- Initial Size (90 chars wide, 10 lines tall)
    -------------------------------------------------------------
    local initWidth  = saved.width  or 630   -- ~90 chars
    local initHeight = saved.height or 400   -- ~10 lines + bars

    -------------------------------------------------------------
    -- Main Frame
    -------------------------------------------------------------
    frame = CreateFrame("Frame", "AutoEquipDebugWindow", UIParent, "BackdropTemplate")
    frame:SetSize(initWidth, initHeight)
    frame:SetFrameStrata("DIALOG")

    -- Restore position if saved
    if saved.x and saved.y then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", saved.x, saved.y)
    else
        frame:SetPoint("CENTER")
    end

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })

    -------------------------------------------------------------
    -- Movable
    -------------------------------------------------------------
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        DebugWindow:SavePosition()
    end)

    -------------------------------------------------------------
    -- Title Bar
    -------------------------------------------------------------
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("AutoEquip Debug Info")

    -------------------------------------------------------------
    -- Close Button (Red X)
    -------------------------------------------------------------
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function() DebugWindow:Hide() end)

    -------------------------------------------------------------
    -- Resize Handle (Bottom Right)
    -------------------------------------------------------------
    frame:SetResizable(true)
    frame:SetMinResize(400, 200)

    local resize = CreateFrame("Button", nil, frame)
    resize:SetPoint("BOTTOMRIGHT", -6, 6)
    resize:SetSize(16, 16)
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

    resize:SetScript("OnMouseDown", function()
        frame:StartSizing("BOTTOMRIGHT")
    end)

    resize:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        DebugWindow:SaveSize()

        -- Update text wrapping width
        textArea:SetWidth(scrollFrame:GetWidth() - 20)
    end)

    -------------------------------------------------------------
    -- Scroll Frame
    -------------------------------------------------------------
    scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    scrollChild = CreateFrame("Frame")
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    textArea = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    textArea:SetPoint("TOPLEFT")
    textArea:SetJustifyH("LEFT")
    textArea:SetJustifyV("TOP")
    textArea:SetWidth(scrollFrame:GetWidth() - 20)
    textArea:SetWordWrap(true)
    textArea:SetText("")

    -------------------------------------------------------------
    -- Bottom Bar Buttons
    -------------------------------------------------------------
    -- Exit (delete buffer + hide)
    local exitBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    exitBtn:SetSize(80, 24)
    exitBtn:SetPoint("BOTTOMLEFT", 16, 16)
    exitBtn:SetText("Exit")
    exitBtn:SetScript("OnClick", function()
        DebugWindow:Reset()
        DebugWindow:Hide()
    end)

    -- Clear (clear text but keep buffer)
    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(80, 24)
    clearBtn:SetPoint("BOTTOMRIGHT", -16, 16)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        DebugWindow:Clear()
    end)

    -- Copy (copy buffer to popup editbox)
    local copyBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    copyBtn:SetSize(80, 24)
    copyBtn:SetPoint("BOTTOM", 0, 16)
    copyBtn:SetText("Copy")
    copyBtn:SetScript("OnClick", function()
        local text = DebugWindow:GetText()
        DebugWindow:ShowCopyPopup(text)
    end)

    -------------------------------------------------------------
    -- Copy Popup
    -------------------------------------------------------------
    function DebugWindow:ShowCopyPopup(text)
        local popup = CreateFrame("Frame", "AutoEquipCopyPopup", UIParent, "BackdropTemplate")
        popup:SetSize(500, 300)
        popup:SetPoint("CENTER")
        popup:SetFrameStrata("DIALOG")

        popup:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })

        local editBox = CreateFrame("EditBox", nil, popup)
        editBox:SetMultiLine(true)
        editBox:SetMaxLetters(99999)
        editBox:SetSize(460, 240)
        editBox:SetPoint("TOP", 0, -20)
        editBox:SetFontObject("GameFontHighlightSmall")
        editBox:SetText(text)
        editBox:HighlightText()

        local close = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
        close:SetSize(80, 24)
        close:SetPoint("BOTTOM", 0, 16)
        close:SetText("Close")
        close:SetScript("OnClick", function() popup:Hide() end)
    end

    -------------------------------------------------------------
    -- Done
    -------------------------------------------------------------
    AutoEquip.DebugWindow.loaded = true
    if core:debuggingIsEnabled() then
	    dbg:print("DebugWindow.lua loaded", 0, 1, 0)
    end
end
