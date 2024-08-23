----------------------------------------------------------------------------------------
-- Locales.lua
-- AUTHOR: mtpeterson1948 at gmail dot com
-- ORIGINAL DATE: 26 April, 2023
----------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.Locales = {}
local locale = AutoEquip.Locales

local dbg = AutoEquip.Debug	-- use for error reporting services
 
local EMPTY_STR = ""
local SUCCESS	= true
local FAILURE	= false

local function getExpansionName( )
    local expansionLevel = GetExpansionLevel()
    local expansionNames = { -- Use a table to map expansion levels to names
        [LE_EXPANSION_DRAGONFLIGHT] = "Dragon Flight",
        [LE_EXPANSION_SHADOWLANDS] = "Shadowlands",
        [LE_EXPANSION_CATACLYSM] = "Classic (Cataclysm)",
        [LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "Classic (WotLK)",
        [LE_EXPANSION_CLASSIC] = "Classic (Vanilla)",

        [LE_EXPANSION_MISTS_OF_PANDARIA] = "Classic (Mists of Pandaria",
        [LE_EXPANSION_LEGION] = "Classic (Legion)",
        [LE_EXPANSION_BATTLE_FOR_AZEROTH] = "Classic (Battle for Azeroth)",
        [LE_EXPANSION_WAR_WITHIN]   = "Retail (The War Within)"
    }
    return expansionNames[expansionLevel] -- Directly return the mapped name
end

-- Form a string representing the library's version number (see WoWThreads.lua).
local MAJOR = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MAJOR")
local MINOR = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MINOR")
local PATCH = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-PATCH")

local version = string.format("%s.%s.%s", MAJOR, MINOR, PATCH )
local expansionName = getExpansionName()

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

AutoEquip.Locales = L

-- English translations
local LOCALE = GetLocale()      -- BLIZZ
if LOCALE == "enUS" then

	L["ADDON_NAME"]			= ADDON_NAME
	L["VERSION"]			= version
	L["EXPANSION_NAME"]		= expansionName 

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["ERROR_MSG_FRAME_TITLE"]			= "Error"
	L["USER_MSG_FRAME"]					= string.format("%s %s", L["ADDON_AND_VERSION"], "User Messages")
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Left Click to display In-Game Options Menu."
	L["HELP_FRAME_TITLE"]				= string.format("Help: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]				= string.format("%s Loaded.", L["ADDON_AND_VERSION"])

	-- bod Specific
	L["LEFTCLICK_FOR_OPTIONS_MENU"]			= string.format( "Left click to display the %s Options Menu.", L["ADDON_NAME"] )

	L["DSCR_SUBHEADER"] = "Auto Save & Restore Your Equipment Sets"

	L["LINE1"]			= string.format("%s is intended to automatically equip an armor set", L["ADDON_NAME"])
	L["LINE2"] 			= "containing one or more Heirloom items whenever the character enters"
	L["LINE3"] 			= "a rest area (e.g, an Inn or a city). The set the character was wearing"
	L["LINE4"]			= "when entering the rest area will be restored when the character leaves."

	L["PARAM_NIL"]				= "Invalid Parameter - Was nil."
	L["ARMOR_SET_NOT_FOUND"]	= "Armor set, %s, not found. Check spelling.\n"
	L["AVAILABLE_SETS"]			= "Available sets: "

end
