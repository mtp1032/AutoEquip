----------------------------------------------------------------------------------------
-- EnUS_AutoEquip.lua
-- AUTHOR: mtpeterson1948 at gmail dot com
-- ORIGINAL DATE: 28 December, 2018
----------------------------------------------------------------------------------------
local _, AutoEquip = ...
AutoEquip.EnUS_AutoEquip = {}
locale = AutoEquip.EnUS_AutoEquip
local sprintf = _G.string.format

locale.EMPTY_STR = ""
locale.SUCCESS	= true
locale.FAILURE	= false

local EXPANSION_NAME 	= nil 
local EXPANSION_LEVEL	= nil
local SUCCESS 	        = locale.SUCCESS
local FAILURE 	        = locale.FAILURE
local EMPTY_STR 	    = locale.EMPTY_STR

local EXPANSION_LEVEL = GetServerExpansionLevel()

if EXPANSION_LEVEL == LE_EXPANSION_CLASSIC then
	EXPANSION_NAME = "Classic (Vanilla)"
end 
if EXPANSION_LEVEL == LE_EXPANSION_WRATH_OF_THE_LICH_KING then 
	EXPANSION_NAME = "Classic (WotLK)"
end
if EXPANSION_LEVEL == LE_EXPANSION_DRAGONFLIGHT then
	EXPANSION_NAME = "Dragon Flight"
end
function locale:getAddonName()
	local stackTrace = debugstack(2)
	local dirNames = nil
	local addonName = nil

	if 	EXPANSION_LEVEL == LE_EXPANSION_DRAGONFLIGHT then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}	end
	if EXPANSION_LEVEL == LE_EXPANSION_WRATH_OF_THE_LICH_KING then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}
	end
	if EXPANSION_LEVEL == LE_EXPANSION_CLASSIC then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}
	end

	addonName = dirNames[1][3]
	return addonName
end

locale.ADDON_NAME 		= locale:getAddonName() 
locale.ADDON_VERSION 	= GetAddOnMetadata( locale.ADDON_NAME, "Version")
local ADDON_NAME		= locale.ADDON_NAME
local ADDON_VERSION		= locale.ADDON_VERSION

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
	L["EXPANSION_NAME"]		= EXPANSION_NAME

	L["ADDON_AND_VERSION"] 	= sprintf("%s (v%s %s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["ERROR_MSG_FRAME_TITLE"]			= "Error"
	L["USER_MSG_FRAME"]					= sprintf("%s %s", L["ADDON_AND_VERSION"], "User Messages")
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Left Click to display In-Game Options Menu."
	L["HELP_FRAME_TITLE"]				= sprintf("Help: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]				= sprintf("%s loaded (Use /boe for help).", L["ADDON_AND_VERSION"])

	-- bod Specific
	L["LEFTCLICK_FOR_OPTIONS_MENU"]			= sprintf( "Left click to display the %s Options Menu.", L["ADDON_NAME"] )
	L["RIGHTCLICK_SHOW_COMBATLOG"]			= "Right click to display the combat log window."
	L["SHIFT_LEFTCLICK_DISMISS_COMBATLOG"]	= "Shift-Left click to dismiss the combat log window."
	L["SHIFT_RIGHTCLICK_ERASE_TEXT"]		= "Shift-Right click to erase the text in the combat log window."

	L["SELECT_BUTTON_TEXT"]					= "Select"
	L["RESET_BUTTON_TEXT"]					= "Reset"
	L["RELOAD_BUTTON_TEXT"]					= "Reload"
	L["CLEAR_BUTTON_TEXT"]					= "Clear"

	L["DSCR_SUBHEADER"] = "Auto Save & Restore Your Equipment Sets"

	L["LINE1"]			= sprintf("By default, %s will display only an encounter's summary.",  L["ADDON_NAME"])
	L["LINE2"] 			= "However, you may enable combat logging (see checkbox below) so that"
	L["LINE3"] 			= sprintf("%s will display a detailed combat log for every event.",  L["ADDON_NAME"])
	L["LINE4"]			= "NOTE: this is very memory intensive. But if you need to see the"
	L["LINE5"] 			= "nitty-gritty details of the fight, check the box below."

    L["ERROR_MSG"]            	= "[ERROR] %s"	
	L["INFO_MSG"]				= "[INFO] %s"

	L["PARAM_NIL"]				= "Invalid Parameter - Was nil."
	L["PARAM_OUTOFRANGE"]		= "Invalid Parameter - Out-of-range."
	L["PARAM_WRONGTYPE"]		= "Invalid Parameter - Wrong type."
	L["PARAM_ILL_FORMED"]	= "[ERROR] Input paramter improperly formed. "

end
if dbg:debuggingIsEnabled() then
	local fileName = "EnUS_AutoEquip.lua"
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end

