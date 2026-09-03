-----------------------------------------------------------------
-- File: MinimapButton.lua
-----------------------------------------------------------------

AutoEquip = AutoEquip or {}
AutoEquip.MinimapButton = AutoEquip.MinimapButton or {}

if not AutoEquip.DebugTools.loaded then
    print("DebugTools.lua failed to load")
    return
end


local MB = AutoEquip.MinimapButton

-- Saved position
-- AUTOEQUIP_SAVED_VARS_DB.minimap = AUTOEQUIP_SAVED_VARS_DB.minimap or {}
-- local saved = AUTOEQUIP_SAVED_VARS_DB.minimap

local button

-----------------------------------------------------------------
-- Calculate position on minimap ring
-----------------------------------------------------------------
local function UpdatePosition(angle)
    local radius = 80
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius

    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-----------------------------------------------------------------
-- Dragging logic
-----------------------------------------------------------------
local function OnDragStart(self)
    self.isDragging = true
    self:StartMoving()
end

local function OnDragStop(self)
    self.isDragging = false
    self:StopMovingOrSizing()

    -- Convert position to angle
    local mx, my = Minimap:GetCenter()
    local bx, by = self:GetCenter()

    local angle = math.atan2(by - my, bx - mx)
    saved.angle = angle

    UpdatePosition(angle)
end

-----------------------------------------------------------------
-- Create minimap button
-----------------------------------------------------------------
function MB:Create()
    if button then return end

    button = CreateFrame("Button", "AutoEquipMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetMovable(true)
    button:RegisterForDrag("LeftButton")

    -------------------------------------------------------------
    -- Icon
    -------------------------------------------------------------
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(894556)  -- your TOC IconTexture
    icon:SetAllPoints()

    -------------------------------------------------------------
    -- Border (Blizzard standard)
    -------------------------------------------------------------
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(56, 56)
    border:SetPoint("CENTER")

    -------------------------------------------------------------
    -- Dragging
    -------------------------------------------------------------
    button:SetScript("OnDragStart", OnDragStart)
    button:SetScript("OnDragStop", OnDragStop)

    -------------------------------------------------------------
    -- Tooltip
    -------------------------------------------------------------
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("AutoEquip")
        GameTooltip:AddLine("Click to open AutoEquip options", 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function() 
        GameTooltip:Hide()
    end)

    -------------------------------------------------------------
    -- Click action (only opens Options)
    -------------------------------------------------------------
    button:SetScript("OnClick", function(self, btn)
        Settings.OpenToCategory("AutoEquip")
    end)

    -------------------------------------------------------------
    -- Initial position
    -------------------------------------------------------------
    local angle = saved.angle or math.rad(45)
    UpdatePosition(angle)
end

    MB.loaded = true
    AutoEquip.MinimapButton.loaded = true
    if AutoEquip.Core:debuggingIsEnabled() then
        print("MinimapButton.lua loaded")
    end
