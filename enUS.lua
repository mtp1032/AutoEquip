-----------------------------------------------------------------
-- File: enUS.lua
-----------------------------------------------------------------

local _, AutoEquip = ...

local fileName = "enUS.lua"

if not AutoEquip.Core or not AutoEquip.Core.loaded then
    print("Core.lua failed to load")
    return
end

local core = AutoEquip.Core

local addonName, addonVersion, addonExpansion = core:getAddonInfo()

local L = setmetatable({}, {
    __index = function(localizationTable, key)
        local value = tostring(key)
        rawset(localizationTable, key, value)
        return value
    end,
})

AutoEquip.L = L

L["ADDON_NAME_AND_VERSION"] =
    string.format(
        "%s version %s (%s) loaded.",
        addonName,
        addonVersion,
        addonExpansion
    )

L["UNKNOWN_EQUIPMENT_SET_NAME"] =
    "Unknown equipment set name. Please check and try again."

L["UNKNOWN_EQUIPMENT_SET_ID"] =
    "Unknown equipment set ID. Please check and try again."

AutoEquip.Localization = {
    loaded = true,
}

if core:isDebuggingEnabled() then
    print(fileName .. " loaded")
end