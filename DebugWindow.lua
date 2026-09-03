-----------------------------------------------------------------
-- File: DebugWindow.lua
-----------------------------------------------------------------

local _, AutoEquip = ...

local fileName = "DebugWindow.lua"

if not AutoEquip.Core or not AutoEquip.Core.loaded then
    print("Core.lua failed to load")
    return
end

if not AutoEquip.DebugTools
    or not AutoEquip.DebugTools.loaded
then
    print("DebugTools.lua failed to load")
    return
end

local core = AutoEquip.Core
local dbg = AutoEquip.DebugTools

local debugWindow = {}
AutoEquip.DebugWindow = debugWindow

local DEFAULT_WIDTH = 630
local DEFAULT_HEIGHT = 400

local MINIMUM_WIDTH = 400
local MINIMUM_HEIGHT = 200

local MAXIMUM_WIDTH = 2000
local MAXIMUM_HEIGHT = 1200

local frame
local scrollFrame
local scrollChild
local textArea
local copyPopup
local copyEditBox
local savedVariables

-----------------------------------------------------------------
-- Private functions
-----------------------------------------------------------------

local function savePosition()
    if not frame or not savedVariables then
        return
    end

    savedVariables.x = frame:GetLeft()
    savedVariables.y = frame:GetTop()
end

local function saveSize()
    if not frame or not savedVariables then
        return
    end

    savedVariables.width = frame:GetWidth()
    savedVariables.height = frame:GetHeight()
end

local function updateDisplay()
    if not textArea then
        return
    end

    textArea:SetText(dbg:getText())

    local textHeight = textArea:GetStringHeight()
    scrollChild:SetHeight(textHeight + 20)

    scrollFrame:SetVerticalScroll(
        scrollFrame:GetVerticalScrollRange()
    )
end

local function createCopyPopup()
    if copyPopup then
        return
    end

    copyPopup =
        CreateFrame(
            "Frame",
            "AutoEquipCopyPopup",
            UIParent,
            "BackdropTemplate"
        )

    copyPopup:SetSize(500, 300)
    copyPopup:SetPoint("CENTER")
    copyPopup:SetFrameStrata("DIALOG")

    copyPopup:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {
            left = 8,
            right = 8,
            top = 8,
            bottom = 8,
        },
    })

    copyEditBox =
        CreateFrame(
            "EditBox",
            nil,
            copyPopup
        )

    copyEditBox:SetMultiLine(true)
    copyEditBox:SetMaxLetters(99999)
    copyEditBox:SetSize(460, 240)
    copyEditBox:SetPoint("TOP", 0, -20)
    copyEditBox:SetFontObject("GameFontHighlightSmall")

    local closeButton =
        CreateFrame(
            "Button",
            nil,
            copyPopup,
            "UIPanelButtonTemplate"
        )

    closeButton:SetSize(80, 24)
    closeButton:SetPoint("BOTTOM", 0, 16)
    closeButton:SetText("Close")

    closeButton:SetScript(
        "OnClick",
        function()
            copyPopup:Hide()
        end
    )
end

local function showCopyPopup()
    createCopyPopup()

    copyEditBox:SetText(dbg:getText())
    copyEditBox:HighlightText()
    copyEditBox:SetFocus()

    copyPopup:Show()
end

local function createWindow()
    if frame then
        return
    end

    if not savedVariables then
        return
    end

    local initialWidth =
        savedVariables.width or DEFAULT_WIDTH

    local initialHeight =
        savedVariables.height or DEFAULT_HEIGHT

    frame =
        CreateFrame(
            "Frame",
            "AutoEquipDebugWindow",
            UIParent,
            "BackdropTemplate"
        )

    frame:SetSize(initialWidth, initialHeight)
    frame:SetFrameStrata("DIALOG")

    if savedVariables.x and savedVariables.y then
        frame:SetPoint(
            "TOPLEFT",
            UIParent,
            "BOTTOMLEFT",
            savedVariables.x,
            savedVariables.y
        )
    else
        frame:SetPoint("CENTER")
    end

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {
            left = 8,
            right = 8,
            top = 8,
            bottom = 8,
        },
    })

    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript(
        "OnDragStart",
        function()
            frame:StartMoving()
        end
    )

    frame:SetScript(
        "OnDragStop",
        function()
            frame:StopMovingOrSizing()
            savePosition()
        end
    )

    local title =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    title:SetPoint("TOP", 0, -12)
    title:SetText("AutoEquip Debug Info")

    local closeButton =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelCloseButton"
        )

    closeButton:SetPoint("TOPRIGHT", -6, -6)

    closeButton:SetScript(
        "OnClick",
        function()
            debugWindow:hide()
        end
    )

    frame:SetResizable(true)

    frame:SetResizeBounds(
        MINIMUM_WIDTH,
        MINIMUM_HEIGHT,
        MAXIMUM_WIDTH,
        MAXIMUM_HEIGHT
    )

    local resizeHandle =
        CreateFrame(
            "Button",
            nil,
            frame
        )

    resizeHandle:SetPoint("BOTTOMRIGHT", -6, 6)
    resizeHandle:SetSize(16, 16)

    resizeHandle:SetNormalTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up"
    )

    resizeHandle:SetHighlightTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight"
    )

    resizeHandle:SetPushedTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down"
    )

    resizeHandle:SetScript(
        "OnMouseDown",
        function()
            frame:StartSizing("BOTTOMRIGHT")
        end
    )

    resizeHandle:SetScript(
        "OnMouseUp",
        function()
            frame:StopMovingOrSizing()

            saveSize()

            textArea:SetWidth(
                scrollFrame:GetWidth() - 20
            )

            updateDisplay()
        end
    )

    scrollFrame =
        CreateFrame(
            "ScrollFrame",
            nil,
            frame,
            "UIPanelScrollFrameTemplate"
        )

    scrollFrame:SetPoint(
        "TOPLEFT",
        16,
        -40
    )

    scrollFrame:SetPoint(
        "BOTTOMRIGHT",
        -30,
        50
    )

    scrollChild =
        CreateFrame(
            "Frame"
        )

    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    textArea =
        scrollChild:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlightSmall"
        )

    textArea:SetPoint("TOPLEFT")
    textArea:SetJustifyH("LEFT")
    textArea:SetJustifyV("TOP")
    textArea:SetWidth(
        scrollFrame:GetWidth() - 20
    )
    textArea:SetWordWrap(true)

    local exitButton =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    exitButton:SetSize(80, 24)
    exitButton:SetPoint(
        "BOTTOMLEFT",
        16,
        16
    )
    exitButton:SetText("Exit")

    exitButton:SetScript(
        "OnClick",
        function()
            dbg:clear()
            updateDisplay()
            debugWindow:hide()
        end
    )

    local clearButton =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    clearButton:SetSize(80, 24)
    clearButton:SetPoint(
        "BOTTOMRIGHT",
        -16,
        16
    )
    clearButton:SetText("Clear")

    clearButton:SetScript(
        "OnClick",
        function()
            dbg:clear()
            updateDisplay()
        end
    )

    local copyButton =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    copyButton:SetSize(80, 24)
    copyButton:SetPoint(
        "BOTTOM",
        0,
        16
    )
    copyButton:SetText("Copy")

    copyButton:SetScript(
        "OnClick",
        function()
            showCopyPopup()
        end
    )

    updateDisplay()
end

-----------------------------------------------------------------
-- Public functions
-----------------------------------------------------------------

function debugWindow:initialize()
    if self.initialized then
        return
    end

    if not core.initialized then
        error(
            "DebugWindow cannot initialize before Core initialization."
        )
    end

    local database =
        core:getSavedVariables()

    if not database then
        error(
            "DebugWindow could not access AutoEquip SavedVariables."
        )
    end

    savedVariables =
        database.debugWindow

    dbg:setMessageHandler(
        function()
            updateDisplay()
        end
    )

    self.initialized = true

    dbg:print(
        fileName .. " initialized"
    )
end

function debugWindow:show()
    createWindow()

    if frame then
        updateDisplay()
        frame:Show()
    end
end

function debugWindow:hide()
    if frame then
        frame:Hide()
    end
end

function debugWindow:clear()
    dbg:clear()
    updateDisplay()
end

function debugWindow:showCopyPopup()
    showCopyPopup()
end

-----------------------------------------------------------------
-- Module state
-----------------------------------------------------------------

debugWindow.loaded = true
debugWindow.initialized = false

if core:isDebuggingEnabled() then
    print(fileName .. " loaded")
end

-----------------------------------------------------------------
-- TESTING ONLY
-----------------------------------------------------------------

SLASH_AUTOEQUIPDEBUG1 = "/aedebug"

SlashCmdList.AUTOEQUIPDEBUG = function()
    print(
        "loaded:",
        debugWindow.loaded,
        "initialized:",
        debugWindow.initialized,
        "savedVariables:",
        savedVariables ~= nil
    )

    if frame and frame:IsShown() then
        debugWindow:hide()
    else
        debugWindow:show()

        dbg:print(
            "Debug window opened. Use /aedebug to toggle visibility."
        )
    end
end