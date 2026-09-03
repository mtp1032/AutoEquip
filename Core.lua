-----------------------------------------------------------------
-- File: AutoEquip.lua
-----------------------------------------------------------------
-- Ensure SkillUp namespace exists
local ADDON_NAME, _ = ...
local Filename = "Core.lua"

AutoEquip = AutoEquip or {}
AutoEquip.Core = {}

local core = AutoEquip.Core

local addonVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "dev"

-- ================================================================
-- Addon Information
-- ================================================================
local function getExpansionName()
    local expansionLevel = GetExpansionLevel()

    local expansionNames = {
        [LE_EXPANSION_CLASSIC]                = "Classic",
        [LE_EXPANSION_BURNING_CRUSADE]        = "Burning Crusade",
        [LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "Wrath of the Lich King",
        [LE_EXPANSION_CATACLYSM]              = "Cataclysm",
        [LE_EXPANSION_MISTS_OF_PANDARIA]      = "Mists of Pandaria",
        [LE_EXPANSION_WARLORDS_OF_DRAENOR]    = "Warlords of Draenor",
        [LE_EXPANSION_LEGION]                 = "Legion",
        [LE_EXPANSION_BATTLE_FOR_AZEROTH]     = "Battle for Azeroth",
        [LE_EXPANSION_SHADOWLANDS]            = "Shadowlands",
        [LE_EXPANSION_DRAGONFLIGHT]           = "Dragonflight",
        [LE_EXPANSION_WAR_WITHIN]             = "The War Within",
        [LE_EXPANSION_MIDNIGHT]               = "Midnight",
    }
    return expansionNames[expansionLevel] or select(4, GetBuildInfo())
end

-- USAGE: local addonName, addonVersion, expansionName = core:getAddonInfo()
-- RETURNS: AutoEquip, 0.0.1 (Midnight)
function core:getAddonInfo()
    local expansionName = getExpansionName()
    return ADDON_NAME, addonVersion, expansionName 
end

-- ================================================================
-- Debugging
-- ================================================================
local DEBUGGING_ENABLED = true

function core:debuggingIsEnabled() 
    return DEBUGGING_ENABLED or (AutoEquip.DEBUGGING == true)
end
function core:enableDebugging()
    DEBUGGING_ENABLED = true
    -print("Debug mode enabled")
end
function core:disableDebugging()
    DEBUGGING_ENABLED = false
    print("Debug mode disabled")
end

-- Mark as loaded
AutoEquip.Core.loaded = true
if AutoEquip.Core and AutoEquip.Core:debuggingIsEnabled() then
    local isLoadedStr = string.format("%s loaded", Filename)
    print(isLoadedStr)
end
