-----------------------------------------------------------------
-- File: DebugTools.lua
-----------------------------------------------------------------
local ADDON_NAME, _ = ...
local Filename = "DebugTools.lua"

AutoEquip = AutoEquip or {}
AutoEquip.DebugTools = AutoEquip.DebugTools or {}

if not AutoEquip.enUS.loaded then
    local failMsg = string.format("%s failed to load", "enUS.lua" )
    print(failMsg) 
    return
end

local core  = AutoEquip.Core
local L     = AutoEquip.enUS.L
local dbg   = AutoEquip.DebugTools

-- ADDON_NAME for ADDON_LOADED
local ADDON_NAME = ...

-----------------------------------------------------------------
-- LOCAL REFERENCES TO SAVED VARIABLES
-----------------------------------------------------------------

local saved   -- bound during ADDON_LOADED
local frame, scrollFrame, scrollChild, textArea

-----------------------------------------------------------------
-- SAVED-VARIABLE INITIALIZATION (unified pattern)
-----------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(self, event, addon)
    if addon ~= ADDON_NAME then return end

    AUTOEQUIP_SAVED_VARS_DB = AUTOEQUIP_SAVED_VARS_DB or {}
    AUTOEQUIP_SAVED_VARS_DB.debugWindow = AUTOEQUIP_SAVED_VARS_DB.debugWindow or {}

    saved = AUTOEQUIP_SAVED_VARS_DB.debugWindow

    eventFrame:UnregisterEvent("ADDON_LOADED")
end)

-----------------------------------------------------------------
-- PREFIX / STACK TRACE
-----------------------------------------------------------------

local function prefix(stackTrace)
    stackTrace = stackTrace or debugstack(3)

    local fileName, lineNumber = stackTrace:match("[\\/]([^\\/:]+):(%d+)")
    if not fileName or not lineNumber then
        return "[Unknown:0] "
    end

    return string.format("[%s:%d] ", fileName, tonumber(lineNumber))
end

-----------------------------------------------------------------
-- Public Debugging Tools
-----------------------------------------------------------------

function dbg:print(...)
    local prefixStr = prefix(debugstack(2))
    local args = { ... }
    local out = {}

    for i = 1, #args do
        local v = args[i]

        if v == nil then
            v = "<nil>"
        elseif type(v) ~= "string" then
            v = tostring(v)
        end

        out[#out + 1] = v
    end

    local msg = table.concat(out, " ")
    msg = prefixStr .. msg
    print(msg)
    self:Append(msg)
end

function dbg:enable()
    core:enableDebugging()
    return true
end

function dbg:disable()
    core:disableDebugging()
    return false
end

-----------------------------------------------------------------
-- Internal buffer of debug lines
-----------------------------------------------------------------

dbg.buffer = {}

-----------------------------------------------------------------
-- Save Position / Size
-----------------------------------------------------------------

function dbg:SavePosition()
    if not frame or not saved then return end
    local x, y = frame:GetLeft(), frame:GetTop()
    saved.x, saved.y = x, y
end

function dbg:SaveSize()
    if not frame or not saved then return end
    saved.width  = frame:GetWidth()
    saved.height = frame:GetHeight()
end

-----------------------------------------------------------------
-- Append a line of text to the debug window
-----------------------------------------------------------------

function dbg:Append(msg)
    if not saved then
        -- Saved variables not ready; avoid creating window too early.
        return
    end

    if not frame then
        self:Create()
    end

    table.insert(self.buffer, msg)

    textArea:SetText(table.concat(self.buffer, "\n"))

    local height = textArea:GetStringHeight()
    scrollChild:SetHeight(height + 20)

    scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
end

-----------------------------------------------------------------
-- Clear / Reset / GetText
-----------------------------------------------------------------

function dbg:Clear()
    if not frame then return end
    textArea:SetText("")
    scrollChild:SetHeight(20)
end

function dbg:Reset()
    self.buffer = {}
    self:Clear()
end

function dbg:GetText()
    return table.concat(self.buffer, "\n")
end

-----------------------------------------------------------------
-- Show / Hide
-----------------------------------------------------------------

function dbg:Show()
    if not saved then return end
    if not frame then
        self:Create()
    end
    frame:Show()
end

function dbg:Hide()
    if frame then
        frame:Hide()
    end
end

-----------------------------------------------------------------
-- Create the debug window
-----------------------------------------------------------------

function dbg:Create()
    if frame then return end
    if not saved then
        -- Saved variables not initialized yet; bail.
        return
    end

    -------------------------------------------------------------
    -- Initial Size (90 chars wide, 10 lines tall)
    -------------------------------------------------------------
    local initWidth  = saved.width  or 630   -- ~90 chars
    local initHeight = saved.height or 400   -- ~10 lines + bars

    -------------------------------------------------------------
    -- Main Frame
    -------------------------------------------------------------
    frame = CreateFrame("Frame", "AutoEquipDebugTools", UIParent, "BackdropTemplate")
    frame:SetSize(initWidth, initHeight)
    frame:SetFrameStrata("DIALOG")

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
        dbg:SavePosition()
    end)

    -------------------------------------------------------------
    -- Title Bar
    -------------------------------------------------------------
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("AutoEquip Debug Info")

    -------------------------------------------------------------
    -- Close Button
    -------------------------------------------------------------
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function() dbg:Hide() end)

    -------------------------------------------------------------
    -- Resize Handle
    -------------------------------------------------------------
    frame:SetResizable(true)
    frame:SetResizeBounds(400, 200, 2000, 1200) 
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
        dbg:SaveSize()
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
    local exitBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    exitBtn:SetSize(80, 24)
    exitBtn:SetPoint("BOTTOMLEFT", 16, 16)
    exitBtn:SetText("Exit")
    exitBtn:SetScript("OnClick", function()
        dbg:Reset()
        dbg:Hide()
    end)

    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(80, 24)
    clearBtn:SetPoint("BOTTOMRIGHT", -16, 16)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        dbg:Clear()
    end)

    local copyBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    copyBtn:SetSize(80, 24)
    copyBtn:SetPoint("BOTTOM", 0, 16)
    copyBtn:SetText("Copy")
    copyBtn:SetScript("OnClick", function()
        local text = dbg:GetText()
        dbg:ShowCopyPopup(text)
    end)
end

-----------------------------------------------------------------
-- Copy Popup
-----------------------------------------------------------------

function dbg:ShowCopyPopup(text)
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
    editBox:SetText(text or "")
    editBox:HighlightText()

    local close = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    close:SetSize(80, 24)
    close:SetPoint("BOTTOM", 0, 16)
    close:SetText("Close")
    close:SetScript("OnClick", function() popup:Hide() end)
end

-----------------------------------------------------------------
-- Loaded flag
-----------------------------------------------------------------

AutoEquip.DebugTools.loaded = true
if core:debuggingIsEnabled() then
    local isLoadedStr = string.format("%s loaded", Filename)
    print(isLoadedStr)
end
