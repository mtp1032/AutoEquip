-----------------------------------------------------------------
-- File: MinimapButton.lua
-----------------------------------------------------------------

local _, AutoEquip = ...

local fileName = "MinimapButton.lua" 

if not AutoEquip.Core or not AutoEquip.Core.loaded then
    print("Core.lua failed to load")
    return
end

local core = AutoEquip.Core

local minimapButton = {}
AutoEquip.MinimapButton = minimapButton

local MINIMAP_RADIUS = 80
local ICON_TEXTURE = 894556

local button
local savedVariables

local function updatePosition()
    if not button or not savedVariables then
        return
    end

    local angle = savedVariables.angle or 0

    local radians = math.rad(angle)

    local x = math.cos(radians) * MINIMAP_RADIUS
    local y = math.sin(radians) * MINIMAP_RADIUS

    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function updateAngleFromCursor()
    if not savedVariables then
        return
    end

    local minimapX, minimapY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()

    local scale = UIParent:GetEffectiveScale()

    cursorX = cursorX / scale
    cursorY = cursorY / scale

    local angle =
        math.deg(
            math.atan2(
                cursorY - minimapY,
                cursorX - minimapX
            )
        )

    savedVariables.angle = angle

    updatePosition()
end

local function onDragStart(self)
    self:SetScript("OnUpdate", updateAngleFromCursor)
end

local function onDragStop(self)
    self:SetScript("OnUpdate", nil)

    updateAngleFromCursor()
end

local function showTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")

    GameTooltip:AddLine("AutoEquip")
    GameTooltip:AddLine("Click to open AutoEquip options.", 1, 1, 1)

    GameTooltip:Show()
end

local function hideTooltip()
    GameTooltip:Hide()
end

local function openOptions()
    Settings.OpenToCategory("AutoEquip")
end

local function createButton()
    if button then
        return
    end

    button =
        CreateFrame(
            "Button",
            "AutoEquipMinimapButton",
            Minimap
        )

    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)

    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    local background =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    background:SetSize(20, 20)
    background:SetPoint("CENTER")
    background:SetTexture(
        "Interface\\Minimap\\UI-Minimap-Background"
    )

    local icon =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    icon:SetSize(18, 18)
    icon:SetPoint("CENTER")
    icon:SetTexture(ICON_TEXTURE)
    icon:SetTexCoord(
        0.08,
        0.92,
        0.08,
        0.92
    )

    local border =
        button:CreateTexture(
            nil,
            "OVERLAY"
        )

    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")
    border:SetTexture(
        "Interface\\Minimap\\MiniMap-TrackingBorder"
    )

    button:SetScript("OnClick", openOptions)
    button:SetScript("OnDragStart", onDragStart)
    button:SetScript("OnDragStop", onDragStop)
    button:SetScript("OnEnter", showTooltip)
    button:SetScript("OnLeave", hideTooltip)

    updatePosition()
end

function minimapButton:initialize()
    if self.initialized then
        return
    end

    if not core.initialized then
        error(
            "MinimapButton cannot initialize before Core initialization."
        )
    end

    AUTOEQUIP_SAVED_VARS_DB.minimap =
        AUTOEQUIP_SAVED_VARS_DB.minimap or {}

    savedVariables =
        AUTOEQUIP_SAVED_VARS_DB.minimap

    createButton()

    self.initialized = true

    if core:isDebuggingEnabled()
        and AutoEquip.DebugTools
        and AutoEquip.DebugTools.loaded
    then
        AutoEquip.DebugTools:print(
            fileName .. " initialized"
        )
    end
end

minimapButton.loaded = true
if core:isDebuggingEnabled() then
    print(fileName .. " loaded")
end