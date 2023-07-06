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

local sprintf = _G.string.format

local autoEquipSavedVars	= {}
AUTO_EQUIP_XPSET_ID			= nil
AUTO_EQUIP_NONXP_SET_ID 	= nil

local INDEX_RESTXP_SET	= 1
local INDEX_SAVED_SET 	= 2
local dbg = equipdbg

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
function equip:setRestXpSet( setName ) -- Set only via the options menu
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

	local errMsg = nil
	-- post error if set name poorly formed.
	if setName == nil or setName == EMPTY_STR then
		errMsg = L["PARAM_NIL"]
		result = equipdbg:setResult( errMsg, equipdbg:simpleStackTrace() )
		if not result[1] then return result end
	end

	local restSetId = getSetIdByName( setName )
	-- post error if the input set does not exist
	if restSetId == nil then
		errMsg = sprintf(L["ARMOR_SET_NOT_FOUND"], setName )
		local setNames = enumSetNames()
		local namesStr = sprintf("%s", setNames[1])
		for i = 2, #setNames do
			namesStr = namesStr .. sprintf(", %s", setNames[i])
		end
		local setNames = L["AVAILABLE_SETS"] .. namesStr
		local errMsg = sprintf("%s %s", errMsg, setNames ) 
		result = equipdbg:setResult( errMsg, equipdbg:simpleStackTrace() )
		if not result[1] then return result end
	end
	local equippedSetName, equippedSetId = getEquippedSet()

	AUTO_EQUIP_NONXP_SET_ID = equippedSetId
	AUTO_EQUIP_XPSET_ID 	= restSetId 

	autoEquipSavedVars[INDEX_SAVED_SET] = AUTO_EQUIP_NONXP_SET_ID
	autoEquipSavedVars[INDEX_RESTXP_SET] = AUTO_EQUIP_XPSET_ID

	C_UI.Reload()
	return result
end

local eventFrame = CreateFrame("Frame" )
eventFrame:RegisterEvent( "ADDON_LOADED")
eventFrame:RegisterEvent( "PLAYER_UPDATE_RESTING")

eventFrame:SetScript("OnEvent",
function( self, event, ... )
	local arg =	{...}
	local prevId = nil
	local currentId = nil

	if event == "PLAYER_UPDATE_RESTING" then
		if AUTO_EQUIP_XPSET_ID 		== nil then print("Rest Set Has Not Been Set") return end
		if AUTO_EQUIP_NONXP_SET_ID 	== nil then print("DPS Set Nas Not Been Set") return end

		local msg = nil

		if IsResting() then -- ENTERING a resting zone. Equip the INDEX_RESTXP_SET set

			-- save the set the player was wearing when entering the resting zone
			_, autoEquipSavedVars[INDEX_SAVED_SET] = getEquippedSet()
			local savedSet = getSetNameByID( autoEquipSavedVars[INDEX_SAVED_SET])

			-- Now, switch to the resting XP set, the heirloom set
			equipSetByID( autoEquipSavedVars[INDEX_RESTXP_SET] )
			
			local setName = getSetNameByID( autoEquipSavedVars[INDEX_RESTXP_SET])
			msg = sprintf("ENTERED Rest area: %s has been equipped. %s saved.", setName, savedSet )
			UIErrorsFrame:AddMessage( msg, 0.0, 1.0, 0.0 )

		else	-- LEAVING rested zone. EQUIP the SAVED_SET set

			equipSetByID( autoEquipSavedVars[INDEX_SAVED_SET])
			local restedSet = getSetNameByID( autoEquipSavedVars[INDEX_RESTXP_SET])
			
			local setName = getSetNameByID( autoEquipSavedVars[INDEX_SAVED_SET])
			msg = sprintf("LEFT Rest area: %s has been equipped. %s has been saved.", setName, restedSet )
			UIErrorsFrame:AddMessage( msg, 0.0, 1.0, 0.0 )
		end
		return
	end

	if event == "ADDON_LOADED" and arg[1] == L["ADDON_NAME"] then

		DEFAULT_CHAT_FRAME:AddMessage( L["ADDON_LOADED_MSG"],  1.0, 1.0, 0.0 )

		if AUTO_EQUIP_XPSET_ID ~= nil then
			autoEquipSavedVars[INDEX_RESTXP_SET] = AUTO_EQUIP_XPSET_ID
		end
		if AUTO_EQUIP_NONXP_SET_ID ~= nil then
			autoEquipSavedVars[INDEX_SAVED_SET] = AUTO_EQUIP_NONXP_SET_ID
		end

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
	local setId, setName, isEquipped = getEquippedSet()
	return setName, setId
end
function equip:set( setName ) -- param may be a name (string) or Id (number)
	local setId = getSetIdByName ( setName )
	result = equipSetByID( setId )
	if not result[1] then msgf:postResult( result ) end
end
if equipdbg:debuggingIsEnabled() then
	local fileName = "AutoEquip.lua"
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
