--------------------------------------------------------------------------------------
-- AutoEquip.lua
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 26 April, 2023
local _, AutoEquip = ...
AutoEquip.AutoEquip = {}
equip = AutoEquip.AutoEquip

local L = AutoEquip.L

-- https://wowwiki-archive.fandom.com/wiki/API_IsResting

local sprintf = _G.string.format

autoEquipSavedVars	= nil

local dbg 			= equipdbg
local EMPTY_STR		= dbg.EMPTY_STR
local SUCCESS		= dbg.SUCCESS
local FAILURE		= dbg.FAILURE

function equip:setsAreAvailable()
	local isValid = true
	local reason = nil

	if UnitLevel("Player") < 10 then
		reason = sprintf("ERROR: %s must be level 10 or above to use the equipment manager.", UnitName( "Player"))
		isValid = false
		return isValid, reason
	end
	-- check whether one or more equipment sets are useable
	if not C_EquipmentSet.CanUseEquipmentSets() then
		reason = sprintf("ERROR: No usable equipment sets are available. This error often arises\n because an equipment set is missing one or more items.")
		isValid = false
		return isValid, reason
	end

	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()

	if setIDs == nil or #setIDs == 0 then
		reason = sprintf("ERROR: %s has not yet defined any equipment sets.", UnitName("Player"))
		isValid = false
		return isValid, reason
	end
	return isValid, reason
end
local function enumSetNames()
	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	local ss = nil
	local setNames = {}
	for i = 1, #setIDs do
		local name, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		setNames[i] = name
	end
	return setNames
end
local function getSetNameByID( setId )
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
	local setName = nil

	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	for i = 1, #setIDs do
		local setName, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if setId == id then 
			return setName
		end
	end
	if setName == nil then
		result = equipdbg:setResult(sprintf("Equipment set %d not found", setId ), debugstack(2) )
	end

	return setName, result
end
local function getSetIdByName( setName )
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
	local setId = nil

	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	for i = 1, #setIDs do
		local name, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if name == setName then 
			setId = id
		end
	end
	if setId == nil then
		result = equipdbg:setResult(sprintf("%s equipment set not found", setName ), debugstack(2) )
	end

	return setId, result
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
	if not C_EquipmentSet.CanUseEquipmentSets() then
		return nil, nil, nil
	end
	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	for i = 1, #setIDs do
		local setName, _, setId, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if isEquipped then 
			return setName, setId, isEquipped
		end
	end
	return nil, nil, nil
end
local function equipSetByID( setId )
	local result = { SUCCESS, EMPTY_STR , EMPTY_STR }
	if setId == nil then return result end

	local setName = getSetNameByID( setId )
	if setName == nil then
		local errMsg = sprintf("%d Not found. Set Could not be equipped!\n", setId )
		result = equipdbg:setResult( errMsg, equipdbg:simpleStackTrace() )
		if not result[1] then msgf:postResult( result ) return end
	end
	C_EquipmentSet.UseEquipmentSet( setId ) 
end
local function equipSetByName( setName )
	local result = { SUCCESS, EMPTY_STR , EMPTY_STR }
	local setId, result = getSetIdByName( setName )
	if setId == nil then
		local errMsg = sprintf("%s Not found. Could not be equipped!\n", setName )
		result = equipdbg:setResult( errMsg, equipdbg:simpleStackTrace() )
		if not result[1] then msgf:postResult( result ) return end
	end

	local wasEquipped = C_EquipmentSet.UseEquipmentSet( setId ) 
	if not wasEquipped then
		local errMsg = sprintf("%s could not be equipped.", setName )
		result = equipdbg:setResult( errMsg, equipdbg:simpleStackTrace() )
		if not result[1] then msgf:postResult( result ) return end
	end
end 
function equip:setRestXpSet( inputRestingSetName ) -- Set only via the options menu
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

	local restingSetId, result 	= getSetIdByName( inputRestingSetName )
	if not result[1] then return result end

	local _, equippedSetId = getEquippedSet()
	autoEquipSavedVars 	= { restingSetId, equippedSetId }

	-- If player is already in a resting zone,
	-- equip the rest XP set.
	if IsResting() then 
		C_EquipmentSet.UseEquipmentSet( autoEquipSavedVars[1] )
	end	

	return result
end

local eventFrame = CreateFrame("Frame" )
eventFrame:RegisterEvent( "ADDON_LOADED")
eventFrame:RegisterEvent( "PLAYER_UPDATE_RESTING")
eventFrame:RegisterEvent( "EQUIPMENT_SWAP_PENDING")
eventFrame:RegisterEvent( "EQUIPMENT_SWAP_FINISHED")

eventFrame:SetScript("OnEvent",
function( self, event, ... )
	local arg =	{...}
	if event == "EQUIPMENT_SWAP_FINISHED" then
		-- local setName, setId, isEquipped = getEquippedSet()
	end

	if event == "EQUIPMENT_SWAP_PENDING" then
		-- local setName, setId, isEquipped = getEquippedSet()
		-- print( event, "previous set?", setName )
	end

	if event == "PLAYER_UPDATE_RESTING" then
		-- Return if saved vars have not yet been set.
		if autoEquipSavedVars ~= nil then
			if autoEquipSavedVars[1] == nil then return end
			if autoEquipSavedVars[2] == nil then return end
		else
			return
		end

		local msg = nil

		local restingSetName 	= getSetNameByID( autoEquipSavedVars[1] )
		local savedSetName 		= getSetNameByID( autoEquipSavedVars[2])

		local setWasEquipped = nil
		if IsResting() then
			-- Player has entered, or already is in a resting zone. If not already set, 
			-- equip the specified resting XP set.
			setWasEquipped = C_EquipmentSet.UseEquipmentSet( autoEquipSavedVars[1] )
			if not setWasEquipped then
				local result = equipdbg:setResult( "Failed to equip specified set.",debugstack(2))
				msfg:postResult( result )
				return
			end
			msg = sprintf("ENTERED Rest Area: switched to %s (Id = %d).", restingSetName, autoEquipSavedVars[1] )
		else
			-- Player has left the resting zone or is not in one.
			setWasEquipped = C_EquipmentSet.UseEquipmentSet( autoEquipSavedVars[2] )
			if not setWasEquipped then
				local result = equipdbg:setResult( "Failed to equip specified set.", debugstack(2))
				msfg:postResult( result )
				return
			end
			msg = sprintf("LEFT Rest area: switched to %s (Id = %d).", savedSetName, autoEquipSavedVars[2] )
		end
		UIErrorsFrame:AddMessage( msg, 0.0, 1.0, 0.0 )
		DEFAULT_CHAT_FRAME:AddMessage( msg, 0.0, 1.0, 0.0 )
	end
	if event == "ADDON_LOADED" and arg[1] == L["ADDON_NAME"] then

		if autoEquipSavedVars == nil then
			autoEquipSavedVars = {}
		end

		DEFAULT_CHAT_FRAME:AddMessage( L["ADDON_LOADED_MSG"],  1.0, 1.0, 0.0 )
		eventFrame:UnregisterEvent( "ADDON_LOADED")
		return
	end
end)

-- ================ SLASH COMMANDS/TESTS ================
function equip:enumSets()
	local sets = enumSetNames()
	for i = 1, #sets do
		msgf:postMsg( sprintf("%s\n", sets[1]))
	end
end
function equip:getEquippedSet()
	local setName, setId, isEquipped = getEquippedSet()
	return setName, setId, isEquipped
end
function equip:set( setName ) -- param may be a name (string) or Id (number)
	local setId = getSetIdByName ( setName )
	result = C_EquipmentSet.UseEquipmentSet( setId )
	if not result[1] then msgf:postResult( result ) end
end

if dbg:debuggingIsEnabled() then
	local fileName = "AutoEquip.lua"
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end