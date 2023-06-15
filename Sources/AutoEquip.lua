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

AUTO_EQUIP_SVARS	= nil
local HEIRLOOM_SET_ID			= 1
local SAVED_SET_ID 		= 2
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
		-- if isEquipped then
		-- 	ss = sprintf("Equipment Set: %s, Id = %d (Currently EQUIPPED).\n", name, id )
		-- else
		-- 	ss = sprintf("Equipment Set: %s, Id = %d.\n", name, id )
		-- end
		-- msgf:postMsg( ss )
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
		local errMsg = sprintf("%s %d Not found. Set Could not be equipped!\n", dbg:prefix(), setId )
		result = dbg:setResult( errMsg, dbg:simpleStackTrace() )
		return result
	end
	C_EquipmentSet.UseEquipmentSet( setId ) 
	return result
end
local function equipSetByName( setName )
	local result = { SUCCESS, EMPTY_STR , EMPTY_STR }
	local setId, result = getSetIdByName( setName )
	if setId == nil then
		local errMsg = sprintf("%s Not found. Could not be equipped!\n", setName )
		result = dbg:setResult( errMsg, dbg:simpleStackTrace() )
		return result
	end

	local wasEquipped = C_EquipmentSet.UseEquipmentSet( setId ) 
	if not wasEquipped then
		local errMsg = sprintf("%s %s could not be equipped.", dbg:prefix(), setName )
		result = dbg:setResult( errMsg, dbg:simpleStackTrace())
	end

	return result
end 
function equip:setRestXpSet( setName ) -- Set only via the options menu
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

	local errMsg = nil

	if setName == nil or setName == EMPTY_STR then
		errMsg = L["PARAM_NIL"]
		result = dbg:setResult( errMsg )
		return result
	end

	local restSetId = getSetIdByName( setName )
	if restSetId == nil then
		errMsg = sprintf(L["ARMOR_SET_NOT_FOUND"], setName )
		local setNames = enumSetNames()
		local namesStr = sprintf("%s", setNames[1])
		for i = 2, #setNames do
			namesStr = namesStr .. sprintf(", %s", setNames[i])
		end
		local setNames = L["AVAILABLE_SETS"] .. namesStr
		local resultMsg = sprintf("%s %s", errMsg, setNames ) 
		result = dbg:setResult( resultMsg )
		return result
	end

	local equippedSetName, equippedSetId = getEquippedSet()

	AUTO_EQUIP_SVARS[SAVED_SET_ID] = equippedSetId
	AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] = restSetId
	C_UI.Reload()
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
			if AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] == "Not Set" then return result end
			if not setIsEquipped( AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID]) then
				result = equipSetByID( AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID])
				if not result[1] then msgf:postResult( result ) end
			end
		end
	end

	if event == "PLAYER_UPDATE_RESTING" then
		local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
		local enteredRestingZone = IsResting()
		local msg = nil

		if enteredRestingZone then -- ENTERING resting zone. Equip the HEIRLOOM_SET_ID set
			-- save the current set
			_, AUTO_EQUIP_SVARS[SAVED_SET_ID] = getEquippedSet()

			-- switch to the resting set
			if AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] == "Not Set" then return end
			if AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] == "NIL" then return end
			if AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] == nil then return end

			result = equipSetByID( AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] )
			if not result[1] then msgf:postResult( result ) end
			
			local setName = getSetNameByID( AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID])
			msg = sprintf("ENTERED Rest area: %s has been equipped.", setName )
			UIErrorsFrame:AddMessage( msg, 0.0, 1.0, 0.0 )

		else	
			-- LEAVING rested zone. EQUIP the SAVED_SET set
			if AUTO_EQUIP_SVARS[SAVED_SET_ID] == "Not Set" then return end
			if AUTO_EQUIP_SVARS[SAVED_SET_ID] == "NIL" then return end
			if AUTO_EQUIP_SVARS[SAVED_SET_ID] == nil then return end

			result = equipSetByID( AUTO_EQUIP_SVARS[SAVED_SET_ID])
			if not result[1] then msgf:postResult( result ) end

			local setName = getSetNameByID( AUTO_EQUIP_SVARS[SAVED_SET_ID])
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
			if AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] == "Not Set" then return result end
			if AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] == "NIL" then return result end
			if AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID] == nil then return result end
			if setIsEquipped( AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID]) then return result end

			result = equipSetByID( AUTO_EQUIP_SVARS[HEIRLOOM_SET_ID])
			if not result[1] then msgf:postResult( result ) end
		end
		return
	end
	if event == "ADDON_LOADED" and arg[HEIRLOOM_SET_ID] == L["ADDON_NAME"] then

		DEFAULT_CHAT_FRAME:AddMessage( L["ADDON_LOADED_MSG"],  1.0, 1.0, 0.0 )

		if AUTO_EQUIP_SVARS == nil then
			AUTO_EQUIP_SVARS = { "Not Set", "Not Set" }		-- default values
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
if dbg:debuggingIsEnabled() then
	local fileName = "AutoEquip.lua"
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
