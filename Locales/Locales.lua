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

	L["DESCR_SUBHEADER"] = "Auto Save & Restore Your Equipment Sets"

	L["LINE1"]			= string.format("%s is intended to automatically equip an armor set", L["ADDON_NAME"])
	L["LINE2"] 			= "[usually] containing one or more Heirloom items whenever the character enters"
	L["LINE3"] 			= "a rest area (e.g, an Inn or a city). The set the character was wearing"
	L["LINE4"]			= "when entering the rest area will be restored when the character leaves."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip is used to automatically and transparently equip\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("a specific armor set when entering a rest area. Usually\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("this means an armor set containing one or more Heirloom items.\n")
	

	L["EQUIPMENT_SET_NOT_FOUND"]	= "ERROR: Equipment set not found. Check spelling.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERROR: The %s set is missing one or more items.\n"
	L["NO_SETS_EXIST"]				= "ERROR: No equipment sets exist yet. "
	L["LEVEL_REQUIREMENT"]			= "ERROR: %s must be level 10 or above to use the equipment manager."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format( "ERROR: No usable equipment sets are available. This error often arises\n because an equipment set is missing one or more items.")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "ERROR: %s has not yet defined any equipment sets."
	L["LEFT_REST_AREA"]				= "INFO: LEFT Rest area. Equipped %s equipment set. "
	L["ENTERED_REST_AREA"] 			= "INFO: Entered Rest Area. Equipped %s equipment set. "
	L["FAILED_TO_EQUIP_SET"] 		= "ERROR: %s set was not equipped. "
	L["CURRENT_EQUIPPED_SET"]		= "Currently Equipped: %s\n"

end
--[[ 
-- Localization table (typically loaded from a separate file based on the locale)
local L = {}
L["SET_NOT_EQUIPPED"] = "ERROR: Failed to equip set %s"

-- Example of using the localization entry with a dynamic value
local combatSet = "MyCombatSet"
local errorMessage = string.format(L["SET_NOT_EQUIPPED"], combatSet)

-- Print the result or display it to the player
print(errorMessage)  -- Outputs: "ERROR: Failed to equip set MyCombatSet"

]]
