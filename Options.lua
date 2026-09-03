-----------------------------------------------------------------
-- File: Options.lua
-----------------------------------------------------------------
ADDON_NAME, _ = ...
local Filename = "Options.lua"

AutoEquip = AutoEquip or {}
AutoEquip.Options = AutoEquip.Options or {} 

if not AutoEquip.EquipSet.loaded then
    local failMsg = string.format("%s failed to load", "EquipSet.lua" )
    print(failMsg)
    return
end

-- Shortcut references
local core  = AutoEquip.Core 
local dbg   = AutoEquip.DebugTools
local L     = AutoEquip.enUS.L
local equip = AutoEquip.EquipSet

-----------------------------------------------------------------
-- Access saved configuration (exposed from EquipSet.lua)
-----------------------------------------------------------------

local function GetConfig()
    return AutoEquip.config
end

-----------------------------------------------------------------
-- Main Config Window
-----------------------------------------------------------------

local configFrame = CreateFrame("Frame", "AutoEquipConfigFrame", UIParent, "BackdropTemplate")
configFrame:SetSize(700, 450)
configFrame:SetPoint("CENTER")
configFrame:SetFrameStrata("DIALOG")

configFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile     = true, tileSize = 32, edgeSize = 32,
    insets   = { left = 8, right = 8, top = 8, bottom = 8 },
})

configFrame:Hide()
configFrame:EnableMouse(true)
configFrame:SetMovable(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", configFrame.StartMoving)
configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)

-----------------------------------------------------------------
-- Title Bar
-----------------------------------------------------------------

local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -12)
title:SetText("AutoEquip Configuration")

local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -6, -6)
closeBtn:SetScript("OnClick", function() configFrame:Hide() end)

-----------------------------------------------------------------
-- Left Sidebar
-----------------------------------------------------------------

local sidebar = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
sidebar:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 12, -40)
sidebar:SetPoint("BOTTOMLEFT", configFrame, "BOTTOMLEFT", 12, 12)
sidebar:SetWidth(160)

sidebar:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true, tileSize = 16, edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
})
sidebar:SetBackdropColor(0, 0, 0, 0.8)

-----------------------------------------------------------------
-- Right Content Area
-----------------------------------------------------------------

local contentFrame = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
contentFrame:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 12, 0)
contentFrame:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -12, 12)

contentFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true, tileSize = 16, edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
})

-----------------------------------------------------------------
-- Tabs Definition
-----------------------------------------------------------------

local tabs = {
    { key = "GENERAL",    label = "General" },
    { key = "EQUIP_SETS", label = "Equipment Sets" },
    { key = "DEBUG",      label = "Debug" },
    { key = "ABOUT",      label = "About" },
}

local activeTabKey = "EQUIP_SETS"
local tabButtons   = {}

-----------------------------------------------------------------
-- Content Clearing
-----------------------------------------------------------------

local function ClearContent(parent)
    for _, child in ipairs({ parent:GetChildren() }) do
        child:Hide()
    end
    for _, region in ipairs({ parent:GetRegions() }) do
        if region:GetObjectType() == "FontString" then
            region:SetText("")
        end
    end
end

-----------------------------------------------------------------
-- CreateSetButton (with premium highlight)
-----------------------------------------------------------------

local function CreateSetButton(parent, setName, iconTexture, yOffset, labelText)

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(40, 40)
    btn:SetPoint("TOPLEFT", 16, yOffset)

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(iconTexture)

    btn.icon       = icon
    btn.setName    = setName
    btn.labelText  = labelText

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

    -- Premium highlight: gold border + glow
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    border:SetBlendMode("ADD")
    border:SetSize(60, 60)
    border:SetPoint("CENTER")
    border:Hide()

    local glow = btn:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
    glow:SetBlendMode("ADD")
    glow:SetAllPoints()
    glow:Hide()

    btn.highlightBorder = border
    btn.highlightGlow   = glow

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
-- Highlight Updater
-----------------------------------------------------------------

local function UpdateSetHighlights(content)
    local config = GetConfig()
    if not config then return end

    local resting  = config.restingSetName
    local questing = config.questingSetName

    for _, child in ipairs({ content:GetChildren() }) do
        if child.setName then
            local isResting  = (child.labelText == "Resting Set")
            local isQuesting = (child.labelText == "Questing Set")

            local shouldHighlight =
                (isResting  and child.setName == resting) or
                (isQuesting and child.setName == questing)

            if shouldHighlight then
                child.highlightBorder:Show()
                child.highlightGlow:Show()
            else
                child.highlightBorder:Hide()
                child.highlightGlow:Hide()
            end
        end
    end
end

-----------------------------------------------------------------
-- Tab Builders
-----------------------------------------------------------------

local function BuildGeneralTab(parent)
    ClearContent(parent)

    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 16, -16)
    text:SetWidth(parent:GetWidth() - 32)
    text:SetJustifyH("LEFT")
    text:SetText("General settings for AutoEquip will be added here.\n\n" ..
                 "Currently, configuration focuses on Equipment Sets.")
end

local function BuildDebugTab(parent)
    ClearContent(parent)

    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 16, -16)
    text:SetWidth(parent:GetWidth() - 32)
    text:SetJustifyH("LEFT")
    text:SetText("Debugging:\n\n" ..
                 "- Use /autoequip debug to toggle debugging.\n" ..
                 "- Use the Debug Window to inspect internal behavior.\n")
end

local function BuildAboutTab(parent)
    ClearContent(parent)

    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 16, -16)
    text:SetWidth(parent:GetWidth() - 32)
    text:SetJustifyH("LEFT")
    text:SetText("AutoEquip\n\n" ..
                 "Automatically swaps between Resting and Questing equipment sets.\n\n" ..
                 "Midnight-compatible, using a standalone configuration UI.")
end

-----------------------------------------------------------------
-- Equipment Sets Tab (with deduplication + highlights)
-----------------------------------------------------------------
local function getEquipmentSetNameTable()
    local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
    local seen = {}
    local sets = {}

    for i = 1, #equipmentSetIDs do
        local Id = equipmentSetIDs[i]
        local setName, iconTexture, _, equipped = C_EquipmentSet.GetEquipmentSetInfo(Id)

        if not seen[Id] then
            seen[Id] = true
            table.insert(sets, { name = setName, icon = iconTexture })
        end
    end

    return sets
end
-- I think was we should do is not categorize the buttons by resting/questing, but instead have a 
-- single list of unique equipment sets, and then allow the user to assign each set to either resting or 
--questing. This way, we avoid duplicates and make it clearer which sets are available.
-- In other words, we should have a single list of equipment sets, and then for each set, have two buttons: 
-- one to assign it as the resting set, and one to assign it as the questing set. This way, we avoid duplicates 
-- and make it clearer which sets are available.  
local function BuildEquipSetsTab(parent)
    ClearContent(parent)

    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 16, -16)
    header:SetText("Equipment Sets")

    local sub = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(parent:GetWidth() - 32)
    sub:SetJustifyH("LEFT")
    sub:SetText("Select which Equipment Sets to use for Resting and Questing.\n" ..
                "Click an icon to assign that set.")

    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -30, 50)

    local content = CreateFrame("Frame")
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)

    local sets = getEquipmentSetNameTable()
    local y    = -10

    for i = 1, #sets do
        local name = sets[i].name
        local icon = sets[i].icon

        -- Resting Set Button
        local restingBtn = CreateSetButton(content, name, icon, y, "Resting Set")
        restingBtn:SetScript("OnClick", function(self)
            local ok, err = equip:initializeConfig(self.setName, nil)
            if not ok then
                dbg:print("EquipSet: " .. err)
            else
                dbg:print("Resting set set to:", self.setName)
                UpdateSetHighlights(content)
            end
        end)

        -- Questing Set Button
        local questingBtn = CreateSetButton(content, name, icon, y - 50, "Questing Set")
        questingBtn:SetScript("OnClick", function(self)
            local ok, err = equip:initializeConfig(nil, self.setName)
            if not ok then
                dbg:print("EquipSet: " .. err)
            else
                dbg:print("Questing set set to:", self.setName)
                UpdateSetHighlights(content)
            end
        end)

        y = y - 110
    end

    content:SetHeight(-y + 20)

    -- Apply highlights immediately
    UpdateSetHighlights(content)

    local saveButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    saveButton:SetSize(120, 24)
    saveButton:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 16, 16)
    saveButton:SetText("Save")

    saveButton:SetScript("OnClick", function()
        local ok, err = equip:initializeConfig(nil, nil)
        if not ok then
            dbg:print("EquipSet: " .. err)
            return
        end
        dbg:print("EquipSet: Configuration saved.")
    end)
end

-----------------------------------------------------------------
-- Tab Rendering
-----------------------------------------------------------------

local function RenderActiveTab()
    ClearContent(contentFrame)

    if activeTabKey == "GENERAL" then
        BuildGeneralTab(contentFrame)
    elseif activeTabKey == "EQUIP_SETS" then
        BuildEquipSetsTab(contentFrame)
    elseif activeTabKey == "DEBUG" then
        BuildDebugTab(contentFrame)
    elseif activeTabKey == "ABOUT" then
        BuildAboutTab(contentFrame)
    end
end

-----------------------------------------------------------------
-- Sidebar Tabs
-----------------------------------------------------------------

local function SetActiveTab(tabKey)
    activeTabKey = tabKey

    for key, btn in pairs(tabButtons) do
        if key == tabKey then
            btn:SetNormalFontObject("GameFontHighlight")
        else
            btn:SetNormalFontObject("GameFontNormal")
        end
    end

    RenderActiveTab()
end

local function CreateSidebarTabs()
    local y = -10
    for _, info in ipairs(tabs) do
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetPoint("TOPLEFT", 10, y)
        btn:SetSize(140, 22)

        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")
        btn:SetText(info.label)

        btn:SetScript("OnClick", function()
            SetActiveTab(info.key)
        end)

        tabButtons[info.key] = btn
        y = y - 24
    end

    SetActiveTab(activeTabKey)
end

CreateSidebarTabs()

-----------------------------------------------------------------
-- Slash Command
-----------------------------------------------------------------

SLASH_AUTOEQUIP1 = "/autoequip"
SlashCmdList.AUTOEQUIP = function(msg)
    msg = msg and msg:lower() or ""

    if msg == "debug" then
        if core:debuggingIsEnabled() then
            core:disableDebugging()
            print("AutoEquip debugging disabled.")
        else
            core:enableDebugging()
            print("AutoEquip debugging enabled.")
        end
        return
    end

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
        RenderActiveTab()
    end
end

-----------------------------------------------------------------
-- Loaded Flag
-----------------------------------------------------------------
AutoEquip.Options.loaded = true
if core:debuggingIsEnabled() then
    local isLoadedStr = string.format("%s loaded", Filename)
    print(isLoadedStr)
end
