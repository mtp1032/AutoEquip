AutoEquip = AutoEquip or {}
AutoEquip.Core = {}
local core = AutoEquip.Core

local ADDON_NAME = "AutoEquip"
local addonVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "dev"

-- ================================================================
-- Addon Information
-- ================================================================
local function getExpansionName()
    local expansionLevel = GetServerExpansionLevel()

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

    return expansionNames[expansionLevel] or "Unknown Expansion"
end

-- USAGE:
-- local addonName, addonVersion, expansionName = core:getAddonInfo()
-- AutoEquip, 0.0.1 (Midnight)

function core:getAddonInfo()
    local expansionName = getExpansionName()
    return ADDON_NAME, addonVersion, expansionName
end

-- ================================================================
-- Debug System
-- ================================================================
local DEBUGGING_ENABLED = true

function core:debuggingIsEnabled()
    return DEBUGGING_ENABLED or (AutoEquip.DEBUGGING == true)
end
function core:enableDebugging()
    DEBUGGING_ENABLED = true
    -- print("|cFF00FF00[AutoEquip]|r Debug mode enabled")
end
function core:disableDebugging()
    DEBUGGING_ENABLED = false
    print("|cFF00FF00[AutoEquip]|r Debug mode disabled")
end

-- Mark as loaded
AutoEquip.Core.loaded = true
-- Load message
if AutoEquip.Core and AutoEquip.Core:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage("core.lua loaded", 0, 1, 0)
end
