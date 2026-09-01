-----------------------------------------------------------------
-- File: Options.lua
-----------------------------------------------------------------

AutoEquip = AutoEquip or {}
AutoEquip.Options = AutoEquip.Options or {}

local core  = AutoEquip.Core
local dbg   = AutoEquip.DebugTools
local L     = AutoEquip.enUS.L
local equip  = AutoEquip.EquipSet
local config = AUTOEQUIP_SAVED_VARS_DB.config

-- Ensure AutoEquip.lua loaded
if not AutoEquip.EquipSet.loaded then
    dbg:print("EquipSet.lua not loaded")
    return
end

-----------------------------------------------------------------
-- Create Options Panel (Canvas Layout)
-----------------------------------------------------------------

local panel = CreateFrame("Frame", "AutoEquipOptionsPanel", UIParent)
panel:SetSize(600, 400)
panel.name = "AutoEquip"

-----------------------------------------------------------------
-- Title
-----------------------------------------------------------------

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("AutoEquip Configuration")

-----------------------------------------------------------------
-- Section Header
-----------------------------------------------------------------

local header = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
header:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
header:SetText("Select Equipment Sets")

-----------------------------------------------------------------
-- Scroll Frame (modern layout)
-----------------------------------------------------------------

local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -12)
scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 16)

local content = CreateFrame("Frame")
content:SetSize(1, 1)
scrollFrame:SetScrollChild(content)

-----------------------------------------------------------------
-- Helper: Create an icon button for an equipment set
-----------------------------------------------------------------

local function CreateSetButton(parent, setId, setName, yOffset, labelText)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(40, 40)
    btn:SetPoint("TOPLEFT", 16, yOffset)

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(C_EquipmentSet.GetEquipmentSetIcon(setId))

    btn.icon = icon
    btn.setName = setName

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

    -- Midnight-safe tooltip
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Equipment Set: " .. setName)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", btn, "RIGHT", 12, 0)
    label:SetText(labelText .. ": " .. setName)

    return btn
end

-----------------------------------------------------------------
-- Populate icon buttons for all equipment sets
-----------------------------------------------------------------

local function PopulateSetIcons()
    local sets = C_EquipmentSet.GetEquipmentSetIDs()
    local y = -10

    for _, id in ipairs(sets) do
        local name = C_EquipmentSet.GetEquipmentSetInfo(id)

        -- Resting Set Button
        local restingBtn = CreateSetButton(content, id, name, y, "Resting Set")
        restingBtn:SetScript("OnClick", function(self)
            config.restingSetName = self.setName
            dbg:print("Resting set set to:", self.setName)
        end)

        -- Questing Set Button
        local questingBtn = CreateSetButton(content, id, name, y - 50, "Questing Set")
        questingBtn:SetScript("OnClick", function(self)
            config.questingSetName = self.setName
            dbg:print("Questing set set to:", self.setName)
        end)

        y = y - 110
    end

    content:SetHeight(-y + 20)
end

-----------------------------------------------------------------
-- Save Button
-----------------------------------------------------------------

local saveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
saveButton:SetSize(120, 24)
saveButton:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 0, -12)
saveButton:SetText("Save")

saveButton:SetScript("OnClick", function()
    local ok, err = equip:initializeConfig(config.restingSetName, config.questingSetName)
    if not ok then
        dbg:print("EquipSet: " .. err)
        return
    end

    dbg:print("EquipSet: Configuration saved.")
end)

-----------------------------------------------------------------
-- Panel OnShow
-----------------------------------------------------------------

panel:SetScript("OnShow", function()
    PopulateSetIcons()
end)

-----------------------------------------------------------------
-- Register with Midnight Settings API
-----------------------------------------------------------------

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
category.ID = panel.name

Settings.RegisterAddOnCategory(category)

AutoEquip.Options.loaded = true
if core:debuggingIsEnabled() then
    dbg:print("Options.lua loaded")
end
