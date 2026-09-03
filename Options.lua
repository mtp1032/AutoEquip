-----------------------------------------------------------------
-- File: Options.lua
-----------------------------------------------------------------

local _, AutoEquip = ...

local fileName = "Options.lua"

if not AutoEquip.Core or not AutoEquip.Core.loaded then
    print("Core.lua failed to load")
    return
end

if not AutoEquip.EquipSet
    or not AutoEquip.EquipSet.loaded
then
    print("EquipSet.lua failed to load")
    return
end

local core = AutoEquip.Core
local dbg = AutoEquip.DebugTools
local L = AutoEquip.L
local equipSet = AutoEquip.EquipSet

local options = {}
AutoEquip.Options = options

local ICON_SIZE = 48
local ICON_SPACING = 16
local STARTING_X = 24
local STARTING_Y = -110

local panel
local category

local equipmentSetButtons = {}

-----------------------------------------------------------------
-- Private functions
-----------------------------------------------------------------
local function updateEquipmentSetDisplay()
    local restingSetId =
        equipSet:getRestingSetId()

    local nonRestingSetId =
        equipSet:getNonRestingSetId()

    for _, button in ipairs(equipmentSetButtons) do
        local setId = button.setId

        if button.restingMarker then
            button.restingMarker:SetShown(
                setId == restingSetId
            )
        end

        if button.nonRestingMarker then
            button.nonRestingMarker:SetShown(
                setId == nonRestingSetId
            )
        end
    end
end

local function showEquipmentSetTooltip(button)
    GameTooltip:SetOwner(
        button,
        "ANCHOR_RIGHT"
    )

    GameTooltip:AddLine(
        button.setName
    )

    GameTooltip:AddLine(
        "Left-click: Resting set",
        1,
        1,
        1
    )

    GameTooltip:AddLine(
        "Right-click: Non-resting set",
        1,
        1,
        1
    )

    GameTooltip:Show()
end

local function hideEquipmentSetTooltip()
    GameTooltip:Hide()
end

local function createEquipmentSetButton(
    parent,
    equipmentSet,
    index
)
    local button =
        CreateFrame(
            "Button",
            nil,
            parent
        )

    button:SetSize(
        ICON_SIZE,
        ICON_SIZE
    )

    button:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        STARTING_X
            + ((index - 1)
            * (ICON_SIZE + ICON_SPACING)),
        STARTING_Y
    )

    button:RegisterForClicks(
        "LeftButtonUp",
        "RightButtonUp"
    )

    button.setId = equipmentSet.id
    button.setName = equipmentSet.name

    local icon =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    icon:SetAllPoints()
    icon:SetTexture(
        equipmentSet.icon
    )

    button.icon = icon

    local restingMarker =
        button:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    restingMarker:SetPoint(
        "TOPLEFT",
        button,
        "TOPLEFT",
        2,
        -2
    )

    restingMarker:SetText("R")
    restingMarker:Hide()

    button.restingMarker =
        restingMarker

    local nonRestingMarker =
        button:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    nonRestingMarker:SetPoint(
        "BOTTOMRIGHT",
        button,
        "BOTTOMRIGHT",
        -2,
        2
    )

    nonRestingMarker:SetText("N")
    nonRestingMarker:Hide()

    button.nonRestingMarker =
        nonRestingMarker

    button:SetScript(
        "OnClick",
        function(self, mouseButton)
            if mouseButton == "LeftButton" then
                equipSet:setRestingSetId(
                    self.setId
                )
            elseif mouseButton
                == "RightButton"
            then
                equipSet:setNonRestingSetId(
                    self.setId
                )
            end

            updateEquipmentSetDisplay()
        end
    )

    button:SetScript(
        "OnEnter",
        showEquipmentSetTooltip
    )

    button:SetScript(
        "OnLeave",
        hideEquipmentSetTooltip
    )

    equipmentSetButtons[
        #equipmentSetButtons + 1
    ] = button
end

local function createEquipmentSetButtons()
    local equipmentSets =
        equipSet:getEquipmentSets()

    for index, equipmentSet
        in ipairs(equipmentSets)
    do
        createEquipmentSetButton(
            panel,
            equipmentSet,
            index
        )
    end

    updateEquipmentSetDisplay()
end

local function createOptionsPanel()
    if panel then
        return
    end

    panel =
        CreateFrame(
            "Frame"
        )

    local title =
        panel:CreateFontString(
            nil,
            "ARTWORK",
            "GameFontNormalLarge"
        )

    title:SetPoint(
        "TOPLEFT",
        16,
        -16
    )

    title:SetText(
        "AutoEquip"
    )

    local instructions =
        panel:CreateFontString(
            nil,
            "ARTWORK",
            "GameFontHighlight"
        )

    instructions:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -16
    )

    instructions:SetWidth(600)
    instructions:SetJustifyH("LEFT")

    instructions:SetText(
        "Left-click an equipment set to use it while resting.\n"
        .. "Right-click an equipment set to use it while not resting."
    )

    createEquipmentSetButtons()

    category =
        Settings.RegisterCanvasLayoutCategory(
            panel,
            "AutoEquip"
        )

    Settings.RegisterAddOnCategory(
        category
    )
end

-----------------------------------------------------------------
-- Public functions
-----------------------------------------------------------------

function options:initialize()
    if self.initialized then
        return
    end

    if not core.initialized then
        error(
            "Options cannot initialize before Core initialization."
        )
    end

    if not equipSet.initialized then
        error(
            "Options cannot initialize before EquipSet initialization."
        )
    end

    createOptionsPanel()

    self.initialized = true

    if dbg and dbg.loaded then
        dbg:print(
            fileName .. " initialized"
        )
    end
end

function options:open()
    if not category then
        return
    end

    Settings.OpenToCategory(
        category:GetID()
    )
end
-----------------------------------------------------------------
-- Module state
-----------------------------------------------------------------

options.loaded = true
options.initialized = false

if core:isDebuggingEnabled() then
    print(
        fileName .. " loaded"
    )
end