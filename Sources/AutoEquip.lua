--------------------------------------------------------------------------------------
-- AutoEquip.lua
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 26 April, 2023
local _, AutoEquip = ...
AutoEquip.AutoEquip = {}
equip = AutoEquip.AutoEquip
local L = AutoEquip.L

-- https://wowpedia.fandom.com/wiki/Saving_variables_between_game_sessions
-- https://wowwiki-archive.fandom.com/wiki/API_IsResting

--[[ 	*************** Algorithm ***************
	PLAYER_UPDATE_RESTING
	(1) AUTO_EQUIP_SVARS[XPSET] equipped if IsResting() == true
	(2) AUTO_EQUIP_SVARS[SAVEDSET] equipped if IsResting() == false

PLAYER_LOGIN
	(1) AUTO_EQUIP_SVARS[XPSET] equipped if IsResting() == true
	(2) AUTO_EQUIP_SVARS[SAVEDSET] equipped if IsResting() == false

EQUIPMENT_SWAP_FINISHED: 
	(1) AUTO_EQUIP_SVARS[SAVEDSET] updated.

equip:setDefault()
	(1) AUTO_EQUIP_SVARS[XPSET] is set
 ***********************************************]]

local sprintf = _G.string.format

AUTO_EQUIP_SVARS		= nil

local XPSET		= 1
local SAVEDSET 	= 2

local EMPTY_STR		= dbg.EMPTY_STR
local SUCCESS		= dbg.SUCCESS
local FAILURE		= dbg.FAILURE

local function enumSetNames()
	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	local ss = nil
	local setNames = {}
	for i = 1, #setIDs do
		local name, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if isEquipped then
			ss = sprintf("Equipment Set: %s, id %s. Currently EQUIPPED.\n", name, id )
		else
			ss = sprintf("Equipment Set: %s, id %s.\n", name, id )
		end
		mf:postMsg( ss )
		setNames[i] = name
	end
	mf:postMsg(sprintf("{ %s, %s}\n", AUTO_EQUIP_SVARS[XPSET], AUTO_EQUIP_SVARS[SAVEDSET]))
	return setNames
end
local function getSetNameByID( setId )

	local setName = nil

	local setIDs= C_EquipmentSet.GetEquipmentSetIDs()
	for i = 1, #setIDs do
		local name, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if setId == id then 
			setName = name
		end
	end
	return setName
end
local function getSetIdByName( setName )
	local setId = nil

	local setIDs= C_EquipmentSet.GetEquipmentSetIDs()
	for i = 1, #setIDs do
		local name, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if name == setName then 
			setId = id
		end
	end
	return setId
end
local function setIsEquipped( setId )
	local equipped = false

	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	for i = 1, #setIDs do
		local _, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if setId == id then
			equipped = isEquipped
		end
	end
	return equipped
end
local function getEquippedSet()
	local setId = nil
	local setName = nil
	local isEquipped = nil

	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	for i = 1, #setIDs do
		local name, _, Id, equipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if equipped then 
			setName = name
			setId = Id
			isEquipped = equipped
		end
	end
	return setName, setId, isEquipped
end
local function equipSetByID( setId )
	local result = { SUCCESS, EMPTY_STR , EMPTY_STR }
	print( dbg:prefix(), setId )
	local setName = getSetNameByID( setId )
	if setName == nil then
		local errMsg = sprintf("%s %s Not found. Could not be equipped!\n", dbg:prefix(), setName )
		result = dbg:setResult( errMsg, debugstack() )
		return result
	end
	C_EquipmentSet.UseEquipmentSet( setId ) 
	return result
end
local function equipSetByName( setName )
	local result = { SUCCESS, EMPTY_STR , EMPTY_STR }
	local setId, result = getSetIdByName( setName )
	if setId == nil then
		local errMsg = sprintf("%s %s Not found. Could not be equipped!\n", dbg:prefix(), setName )
		result = dbg:setResult( errMsg, debugstack() )
		return result
	end

	local wasEquipped = C_EquipmentSet.UseEquipmentSet( setId ) 
	if not wasEquipped then
		result = dbg:setResult( sprintf("%s %s could not be equipped.", dbg:prefix(), setName ))
	end

	return result
end 
function equip:setDefault( setName ) -- Set only via the options menu

	local errMsg = nil
	local subMsg = nil

	local setId = getSetIdByName( setName )
	if setId == nil then 
		local errMsg = sprintf("%s %s was nil or does not exist!\n", dbg:prefix(), setName )
		local subMsg = sprintf("You currently have the following equipment sets:\n")
		mf:postMsg( errMsg .. subMsg )

		-- Enumerate the available equipment sets
		local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
		local ss = nil
		for i = 1, #setIDs do
			local ss = nil
			local name, _, Id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
			if isEquipped then
				ss = sprintf("   Equipment Set: %s (Id %d). Currently EQUIPPED.\n", name, Id )
			else
				ss = sprintf("   Equipment Set: %s (id %s).\n", name, Id )
			end
			mf:postMsg( ss)
		end
		return
	end
	C_UI.Reload()
	AUTO_EQUIP_SVARS[XPSET] = setId
	printSavedSet( dbg:prefix() )
end

local eventFrame = CreateFrame("Frame" )
eventFrame:RegisterEvent( "ADDON_LOADED")
eventFrame:RegisterEvent( "PLAYER_LOGIN")
eventFrame:RegisterEvent( "PLAYER_ENTERING_WORLD")
-- eventFrame:RegisterEvent( "EQUIPMENT_SWAP_FINISHED") -- result (boolean), id of set
eventFrame:RegisterEvent( "PLAYER_UPDATE_RESTING")

eventFrame:SetScript("OnEvent",
function( self, event, ... )
	local arg =	{...}
	local prevId = nil
	local currentId = nil

	-- this event equips the resting set if the player hearths into
	-- a rested area (e.g., an inn)
	if event == "PLAYER_ENTERING_WORLD" then

		if IsResting() then	
			if AUTO_EQUIP_SVARS[XPSET] == "NIL" then return result end
			if not setIsEquipped( AUTO_EQUIP_SVARS[XPSET]) then
				result = equipSetByID( AUTO_EQUIP_SVARS[XPSET])
				if not result[1] then mf:postResult( result ) end
			end
		end
	end
	if event == "PLAYER_UPDATE_RESTING" then
		local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
		local enteredRestingZone = IsResting()
		local msg = nil

		if enteredRestingZone then -- ENTERING resting zone. Equip the XPSET set
			if AUTO_EQUIP_SVARS[XPSET] == "NIL" then return end

			-- save the current set
			_, AUTO_EQUIP_SVARS[SAVEDSET] = getEquippedSet()

			-- switch to the XPSET
			result = equipSetByID( AUTO_EQUIP_SVARS[XPSET] )
			if not result[1] then mf:postResult( result ) end
			
			local setName = getSetNameByID( AUTO_EQUIP_SVARS[XPSET])
			msg = sprintf("ENTERED Rest area: %s has been equipped.", setName )
			UIErrorsFrame:AddMessage( msg, 0.0, 1.0, 0.0 )
		else	-- LEAVING rested zone. EQUIP the SAVED_SET set
			if AUTO_EQUIP_SVARS[SAVEDSET] == "NIL" then return end

			result = equipSetByID( AUTO_EQUIP_SVARS[SAVEDSET])
			if not result[1] then mf:postResult( result ) end

			local setName = getSetNameByID( AUTO_EQUIP_SVARS[SAVEDSET])
			msg = sprintf("LEFT Rest area: %s has been equipped.", setName )
			UIErrorsFrame:AddMessage( msg, 0.0, 1.0, 0.0 )
		end
		return
	end
	if event == "EQUIPMENT_SWAP_FINISHED" then
		local equippedSetName = nil

		-- check to see what set has been equipped
		local equippedSetName = getEquippedSet()
		assert( equippedSetName ~= nil, "ASSERT FAILED: getEquippedSet() returned nil.")
		local msg = nil
		if IsResting() then
			msg = sprintf("In RESTING area: %s has been equipped.", equippedSetName )
		else
			msg = sprintf("In GAME area: %s has been equipped", equippedSetName )
		end
		UIErrorsFrame:AddMessage( msg, 0.0, 1.0, 0.0 ) 
		return
	end

	if event == "PLAYER_LOGIN" then -- restore the player's previous equipment set
		local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
	
		if IsResting() then	
			if AUTO_EQUIP_SVARS[XPSET] == "NIL" then return result end
			if not setIsEquipped( AUTO_EQUIP_SVARS[XPSET]) then
				result = equipSetByID( AUTO_EQUIP_SVARS[XPSET])
				if not result[1] then mf:postResult( result ) end
			end
		end
		return
	end
	if event == "ADDON_LOADED" and arg[XPSET] == L["ADDON_NAME"] then

		DEFAULT_CHAT_FRAME:AddMessage( L["ADDON_LOADED_MSG"],  1.0, 1.0, 0.0 )

		if AUTO_EQUIP_SVARS == nil then
			AUTO_EQUIP_SVARS = { "NIL", "NIL" }		-- default values
		end

		eventFrame:UnregisterEvent( "ADDON_LOADED")
		return
	end
end)

-- ================ TESTS ================
function equip:enumSets()
	local sets = enumSetNames()
	for i = 1, #sets do
		mf:postMsg( sprintf("%s\n", sets[1]))
	end
end
function equip:getEquippedSet()
	local setId, setName, isEquipped = getEquippedSet()
	return setName, setId
end
function equip:set( setName ) -- param may be a name (string) or Id (number)
	local setId = getSetIdByName ( setName )
	result = equipSetByID( setId )
	if not result[1] then mf:postResult( result ) end
end
if dbg:debuggingIsEnabled() then
	local fileName = "AutoEquip.lua"
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
