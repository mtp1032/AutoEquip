----------------------------------------------------------------------------------------
-- EnUS_AutoEquip.lua
-- AUTHOR: mtpeterson1948 at gmail dot com
-- ORIGINAL DATE: 26 April, 2023
----------------------------------------------------------------------------------------
local _, AutoEquip = ...
AutoEquip.EnUS_AutoEquip = {}
enus = AutoEquip.EnUS_AutoEquip
local sprintf = _G.string.format

enus.EMPTY_STR = ""
enus.SUCCESS	= true
enus.FAILURE	= false
local dbg = equipdbg

local expansionLevel	= nil
local SUCCESS 	        = enus.SUCCESS
local FAILURE 	        = enus.FAILURE
local EMPTY_STR 	    = enus.EMPTY_STR

local expansionLevel = GetServerExpansionLevel()

function enus:getAddonName()
	local stackTrace = debugstack(2)
	local dirNames = nil
	local addonName = nil

	if 	expansionLevel == LE_EXPANSION_DRAGONFLIGHT then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}	end
	if expansionLevel == LE_EXPANSION_WRATH_OF_THE_LICH_KING then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}
	end
	if expansionLevel == LE_EXPANSION_CLASSIC then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}
	end

	addonName = dirNames[1][3]
	return addonName
end

enus.ADDON_NAME 	= enus:getAddonName() 
enus.ADDON_VERSION 	= GetAddOnMetadata( enus.ADDON_NAME, "Version")
local ADDON_NAME	= enus.ADDON_NAME
local ADDON_VERSION	= enus.ADDON_VERSION

if expansionLevel == LE_EXPANSION_CLASSIC then
	enus.EXPANSION_NAME = "Classic (Vanilla)"
end 
if expansionLevel == LE_EXPANSION_WRATH_OF_THE_LICH_KING then 
	enus.EXPANSION_NAME = "Classic (WotLK)"
end
if expansionLevel == LE_EXPANSION_DRAGONFLIGHT then
	enus.EXPANSION_NAME = "Dragon Flight"
end

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

AutoEquip.L = L

-- English translations
local LOCALE = GetLocale()      -- BLIZZ
if LOCALE == "enUS" then

	L["ADDON_NAME"]			= ADDON_NAME
	L["VERSION"]			= ADDON_VERSION
	L["EXPANSION_NAME"]		= enus.EXPANSION_NAME 

	L["ADDON_AND_VERSION"] 	= sprintf("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["ERROR_MSG_FRAME_TITLE"]			= "Error"
	L["USER_MSG_FRAME"]					= sprintf("%s %s", L["ADDON_AND_VERSION"], "User Messages")
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Left Click to display In-Game Options Menu."
	L["HELP_FRAME_TITLE"]				= sprintf("Help: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]				= sprintf("%s Loaded.", L["ADDON_AND_VERSION"])

	-- bod Specific
	L["LEFTCLICK_FOR_OPTIONS_MENU"]			= sprintf( "Left click to display the %s Options Menu.", L["ADDON_NAME"] )

	L["DSCR_SUBHEADER"] = "Auto Save & Restore Your Equipment Sets"

	L["LINE1"]			= sprintf("%s is intended to automatically equip an armor set", L["ADDON_NAME"])
	L["LINE2"] 			= "containing one or more Heirloom items whenever the character enters"
	L["LINE3"] 			= "a rest area (e.g, an Inn or a city). The set the character was wearing"
	L["LINE4"]			= "when entering the rest area will be restored when the character leaves."

	L["PARAM_NIL"]				= "Invalid Parameter - Was nil."
	L["ARMOR_SET_NOT_FOUND"]	= "Armor set, %s, not found. Check spelling.\n"
	L["AVAILABLE_SETS"]			= "Available sets: "

end
if dbg:debuggingIsEnabled() then
	local fileName = "EnUS_AutoEquip.lua"
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end

