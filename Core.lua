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

-- Get addon version`
local major =
    C_AddOns.GetAddOnMetadata(addonName, "X-MAJOR") or "0"
local minor =
    C_AddOns.GetAddOnMetadata(addonName, "X-MINOR") or "0"
local patch =
    C_AddOns.GetAddOnMetadata(addonName, "X-PATCH") or "0"
local addonVersion =
    string.format("%s.%s.%s", major, minor, patch)

local function getExpansionName()
    local expansionLevel = GetExpansionLevel()
    return EXPANSION_NAMES[expansionLevel]
        or select(4, GetBuildInfo())
end

function core:getAddonInfo()
    return addonName, addonVersion, getExpansionName()
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

eventFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if loadedAddonName ~= addonName then
        return
    end

   AUTOEQUIP_SAVED_VARS_DB =
    AUTOEQUIP_SAVED_VARS_DB or {}

core.initialized = true

if AutoEquip.MinimapButton
    and AutoEquip.MinimapButton.loaded
then
    AutoEquip.MinimapButton:initialize()
end

if AutoEquip.L then
    print(AutoEquip.L["ADDON_NAME_AND_VERSION"])
end

    self:UnregisterEvent("ADDON_LOADED")
end)

core.loaded = true

if core:isDebuggingEnabled() then
    print(fileName .. " loaded")
end

core.loaded = true

if core:isDebuggingEnabled() then
    print(fileName .. " loaded")
end