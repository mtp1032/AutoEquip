-----------------------------------------------------------------
-- File: Core.lua
-----------------------------------------------------------------

local addonName, AutoEquip = ...

local fileName = "Core.lua"
local debuggingEnabled = true

local core = {}
AutoEquip.Core = core

local EXPANSION_NAMES = {
    [LE_EXPANSION_CLASSIC] = "Classic",
    [LE_EXPANSION_BURNING_CRUSADE] = "Burning Crusade",
    [LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "Wrath of the Lich King",
    [LE_EXPANSION_CATACLYSM] = "Cataclysm",
    [LE_EXPANSION_MISTS_OF_PANDARIA] = "Mists of Pandaria",
    [LE_EXPANSION_WARLORDS_OF_DRAENOR] = "Warlords of Draenor",
    [LE_EXPANSION_LEGION] = "Legion",
    [LE_EXPANSION_BATTLE_FOR_AZEROTH] = "Battle for Azeroth",
    [LE_EXPANSION_SHADOWLANDS] = "Shadowlands",
    [LE_EXPANSION_DRAGONFLIGHT] = "Dragonflight",
    [LE_EXPANSION_WAR_WITHIN] = "The War Within",
    [LE_EXPANSION_MIDNIGHT] = "Midnight",
}

local majorVersion =
    C_AddOns.GetAddOnMetadata(addonName, "X-MAJOR") or "0"

local minorVersion =
    C_AddOns.GetAddOnMetadata(addonName, "X-MINOR") or "0"

local patchVersion =
    C_AddOns.GetAddOnMetadata(addonName, "X-PATCH") or "0"

local addonVersion =
    string.format(
        "%s.%s.%s",
        majorVersion,
        minorVersion,
        patchVersion
    )

-----------------------------------------------------------------
-- Private functions
-----------------------------------------------------------------

local function getExpansionName()
    local expansionLevel = GetExpansionLevel()

    return EXPANSION_NAMES[expansionLevel]
        or select(4, GetBuildInfo())
end

local function initializeSavedVariables()
    AUTOEQUIP_SAVED_VARS_DB =
        AUTOEQUIP_SAVED_VARS_DB or {}

    AUTOEQUIP_SAVED_VARS_DB.debugWindow =
        AUTOEQUIP_SAVED_VARS_DB.debugWindow or {}

    AUTOEQUIP_SAVED_VARS_DB.minimap =
        AUTOEQUIP_SAVED_VARS_DB.minimap or {}

    AUTOEQUIP_SAVED_VARS_DB.equipmentSets =
        AUTOEQUIP_SAVED_VARS_DB.equipmentSets or {
            restingSetId = nil,
            nonRestingSetId = nil,
        }
end

local function initializeModules()
    if AutoEquip.DebugWindow
        and AutoEquip.DebugWindow.loaded
    then
        AutoEquip.DebugWindow:initialize()
    end

    if AutoEquip.MinimapButton
        and AutoEquip.MinimapButton.loaded
    then
        AutoEquip.MinimapButton:initialize()
    end

    if AutoEquip.EquipSet
        and AutoEquip.EquipSet.loaded
    then
        AutoEquip.EquipSet:initialize()
    end

    if AutoEquip.Options
        and AutoEquip.Options.loaded
    then
        AutoEquip.Options:initialize()
    end
end
-----------------------------------------------------------------
-- Public functions
-----------------------------------------------------------------

function core:getAddonInfo()
    return addonName, addonVersion, getExpansionName()
end

function core:getSavedVariables()
    if not self.initialized then
        return nil
    end

    return AUTOEQUIP_SAVED_VARS_DB
end

function core:isDebuggingEnabled()
    return debuggingEnabled
end

function core:enableDebugging()
    debuggingEnabled = true
    print("Debug mode enabled")
end

function core:disableDebugging()
    debuggingEnabled = false
    print("Debug mode disabled")
end

-----------------------------------------------------------------
-- Addon initialization
-----------------------------------------------------------------

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript(
    "OnEvent",
    function(self, event, loadedAddonName)
        if loadedAddonName ~= addonName then
            return
        end

        initializeSavedVariables()

        core.initialized = true

        initializeModules()

        if AutoEquip.L then
            print(AutoEquip.L["ADDON_NAME_AND_VERSION"])
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
)

core.loaded = true
core.initialized = false

if core:isDebuggingEnabled() then
    print(fileName .. " loaded")
end