-----------------------------------------------------------------
-- File: enUS.lua
-----------------------------------------------------------------
AutoEquip = AutoEquip or {}
AutoEquip.enUS = AutoEquip.enUS or {}

if not AutoEquip.Core.loaded then
	print("Core.lua failed to load", 1, 0, 0)
    return
end

local core = AutoEquip.Core

local ADDON_NAME, version, addonExpansion = core:getAddonInfo()

local MAJOR = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MAJOR")
local MINOR = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MINOR")
local PATCH = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-PATCH")

local addonVersion = string.format("%s.%s.%s", MAJOR, MINOR, PATCH)

local L = setmetatable({}, {
	__index = function(t, k)
		local v = tostring(k)
		rawset(t, k, v)
		return v
	end
})
AutoEquip.enUS.L = L

local LOCALE = GetLocale() -- BLIZZ
if LOCALE == "enUS" then
	L["ADDON_NAME_AND_VERSION"] = string.format("%s version %s (%s) loaded.", ADDON_NAME, addonVersion, addonExpansion)

	L["UNKNOWN_EQUIPMENT_SET_NAME"] = string.format("Unknown equipment set name. Please check and try again.")
	L["UNKNOWN_EQUIPMENT_SET_ID"] 	= string.format("Unknown equipment set Id. Please check and try again.")
end

AutoEquip.enUS.loaded = true
if core:debuggingIsEnabled() then 
	print("enUS.lua loaded")
end



