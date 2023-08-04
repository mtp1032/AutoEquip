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

	local setName = nil

	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	for i = 1, #setIDs do
		local setName, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo( setIDs[i] )
		if setId == id then 
			return setName
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
		local errMsg = sprintf("%s %d Not found. Set Could not be equipped!\n", equipdbg:prefix(), setId )
		result = equipdbg:setResult( errMsg, equipdbg:simpleStackTrace() )
		if not result[1] then msgf:postResult( result ) return end
	end
	C_EquipmentSet.UseEquipmentSet( setId ) 
end
local function equipSetByName( setName )
	local result = { SUCCESS, EMPTY_STR , EMPTY_STR }
	local setId, result = getSetIdByName( setName )
	if setId == nil then
		local errMsg = sprintf("%s %s Not found. Could not be equipped!\n", equipdbg:prefix(), setName )
		result = equipdbg:setResult( errMsg, equipdbg:simpleStackTrace() )
		if not result[1] then msgf:postResult( result ) return end
	end

	local wasEquipped = C_EquipmentSet.UseEquipmentSet( setId ) 
	if not wasEquipped then
		local errMsg = sprintf("%s %s could not be equipped.", equipdbg:prefix(), setName )
		result = equipdbg:setResult( errMsg, equipdbg:simpleStackTrace() )
		if not result[1] then msgf:postResult( result ) return end
	end
end 
function equip:setRestXpSet( inputRestingSetName ) -- Set only via the options menu

	local restingSetId 	= getSetIdByName( inputRestingSetName )
	local _, equippedSetId = getEquippedSet()
	autoEquipSavedVars 	= { restingSetId, equippedSetId }

	print( dbg:prefix(), "resting Id", restingSetId, "saved Id", equippedSetId )


	-- If player is already in a resting zone,
	-- equip the rest XP set.
	if IsResting() then 
		C_EquipmentSet.UseEquipmentSet( autoEquipSavedVars[1] )
	end	

	C_UI.Reload()
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
		if autoEquipSavedVars == nil then return end
		local msg = nil

		local restingSetName 	= getSetNameByID( autoEquipSavedVars[1] )
		local savedSetName 		= getSetNameByID( autoEquipSavedVars[2])

		if IsResting() then
			-- Player has entered, or already is in a resting zone. If not already set, 
			-- equip the specified resting XP set.
			C_EquipmentSet.UseEquipmentSet( autoEquipSavedVars[1] )
			msg = sprintf("ENTERED Rest Area: switched to %s (Id = %d).", restingSetName, autoEquipSavedVars[1] )
		else
			-- Player has left the resting zone or is not in one.
			C_EquipmentSet.UseEquipmentSet( autoEquipSavedVars[2] )
			msg = sprintf("LEFT Rest area: switched to %s (Id = %d).", savedSetName, autoEquipSavedVars[2] )
		end
		UIErrorsFrame:AddMessage( msg, 0.0, 0.5, 0.5 )
		DEFAULT_CHAT_FRAME:AddMessage( msg, 0.0, 0.5, 0.5 )
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

local fileName = "AutoEquip.lua"
DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
