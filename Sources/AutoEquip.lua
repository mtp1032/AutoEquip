--------------------------------------------------------------------------------------
-- AutoEquip.lua
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 26 April, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ...

------------------------------------------------------------
--                  NAMESPACE LAYOUT
------------------------------------------------------------
AutoEquip = AutoEquip or {}
AutoEquip.AutoEquip = {}
local auto = AutoEquip.AutoEquip

local L = AutoEquip.Locales
local dbg = AutoEquip.Debug	-- use for error reporting services
local EMPTY_STR = ""
local SUCCESS = true
local FAILURE = false

-- Ensure the saved variables are declared and accessible
if autoEquip_SavedRestingSetId == nil then
    autoEquip_SavedRestingSetId = nil
end

if autoEquip_SavedPriorSetId == nil then
    autoEquip_SavedPriorSetId = nil
end

-- Function to initialize saved variables
local function initializeSavedVariables()
    if autoEquip_SavedRestingSetId == nil then
        autoEquip_SavedRestingSetId = nil
    end
    if autoEquip_SavedPriorSetId == nil then
        autoEquip_SavedPriorSetId = nil
    end
end

function auto:setsAreAvailable()
    local isValid = true
    local reason = nil

    if UnitLevel("Player") < 10 then
        reason = string.format("ERROR: %s must be level 10 or above to use the equipment manager.", UnitName("Player"))
        isValid = false
        return isValid, reason
    end
    -- check whether one or more equipment sets are useable
    if not C_EquipmentSet.CanUseEquipmentSets() then
        reason = string.format("ERROR: No usable equipment sets are available. This error often arises\n because an equipment set is missing one or more items.")
        isValid = false
        return isValid, reason
    end

    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()

    if setIDs == nil or #setIDs == 0 then
        reason = string.format("ERROR: %s has not yet defined any equipment sets.", UnitName("Player"))
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
        local name, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setIDs[i])
        setNames[i] = name
    end
    return setNames
end

local function getSetNameByID(setId)
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local setName = nil

    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIDs do
        local setName, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setIDs[i])
        if setId == id then 
            return setName
        end
    end
    if setName == nil then
        result = dbg:setResult(string.format("Equipment set %d not found", setId), debugstack(2))
    end

    return setName, result
end

local function getSetIdByName(setName)
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local setId = nil

    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIDs do
        local name, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setIDs[i])
        if name == setName then 
            setId = id
        end
    end
    if setId == nil then
        result = dbg:setResult(string.format("%s equipment set not found", setName), debugstack(2))
    end

    return setId, result
end

local function setIsEquipped(setId)
    local equipped = false

    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIDs do
        local _, _, id, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setIDs[i])
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
        local setName, _, setId, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setIDs[i])
        if isEquipped then 
            return setName, setId, isEquipped
        end
    end
    return nil, nil, nil
end

local function equipSetByID(setId)
    local result = { SUCCESS, EMPTY_STR, EMPTY_STR }
    if setId == nil then
        result = dbg:setResult(errMsg, dbg:simpleStackTrace())
        return result
    end
    
    local setName = getSetNameByID(setId)
    if setName == nil then
        local errMsg = string.format("%d Not found. Set Could not be equipped!\n", setId)
        result = dbg:setResult(errMsg, dbg:simpleStackTrace())
        return result
    end
    C_EquipmentSet.UseEquipmentSet(setId)
    return result
end

local function equipSetByName(setName)
    local result = { SUCCESS, EMPTY_STR, EMPTY_STR }
    local setId, result = getSetIdByName(setName)
    if setId == nil then
        local errMsg = string.format("Id corresponding to %s Not found!\n", setName)
        result = dbg:setResult(errMsg, dbg:simpleStackTrace())
        return result
    end

    local wasEquipped = C_EquipmentSet.UseEquipmentSet(setId)
    if not wasEquipped then
        local errMsg = string.format("%s could not be equipped.", setName)
        result = dbg:setResult(errMsg, dbg:simpleStackTrace())
        return result
    end
    return result
end

function auto:setRestXpSet(inputXPsetName) -- Set only via the options menu
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

    local restingSetId, result = getSetIdByName(inputXPsetName)
    if not result[1] then return result end

    local _, currentSetId = getEquippedSet()
    autoEquip_SavedRestingSetId = restingSetId
    autoEquip_SavedPriorSetId = currentSetId

    -- If player is already in a resting zone and his resting set is not equipped,
    -- then equip the rest XP set.
    if IsResting() then 
        if not setIsEquipped(autoEquip_SavedRestingSetId) then
            local status = C_EquipmentSet.UseEquipmentSet(autoEquip_SavedRestingSetId)
            if status == nil then
                local result = dbg:setResult("Failed to equip specified set.", debugstack(2))
                return result
            end
        end
    end
    return result
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
eventFrame:RegisterEvent("EQUIPMENT_SWAP_PENDING")
eventFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")

eventFrame:SetScript("OnEvent",
function(self, event, ...)
    local arg = {...}

    if event == "PLAYER_UPDATE_RESTING" then
        -- PLAYER_UPDATE_RESTING is fired when the player enters or leaves a resting area

        local msg = nil
        local restingSetName = getSetNameByID(autoEquip_SavedRestingSetId)
        local savedSetName = getSetNameByID(autoEquip_SavedPriorSetId)
        local setWasEquipped = nil

        if IsResting() then
            -- Player has entered a resting area. If the player is not wearing
            -- his resting set, then equip it. If he is, do nothing.
            if not setIsEquipped(autoEquip_SavedRestingSetId) then
                local status = C_EquipmentSet.UseEquipmentSet(autoEquip_SavedRestingSetId)
                if status == nil then
                    local result = dbg:setResult("Failed to equip specified set.", debugstack(2))
                    return result
                end
            end
            msg = string.format("ENTERED Rest Area: switched to %s (Id = %d).", restingSetName)
        else
            -- Player has left the resting zone. Equip the saved set
            setWasEquipped = C_EquipmentSet.UseEquipmentSet(autoEquip_SavedPriorSetId)
            if not setWasEquipped then
                local result = dbg:setResult("Failed to equip specified set.", debugstack(2))
                return result
            end
            msg = string.format("LEFT Rest area: switched to %s.", savedSetName)
        end
        UIErrorsFrame:AddMessage(msg, 0.0, 1.0, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0)
    end

    if event == "ADDON_LOADED" and arg[1] == "AutoEquip" then
        initializeSavedVariables()
        -- Unregister the event after initializing
        DEFAULT_CHAT_FRAME:AddMessage(L["ADDON_AND_VERSION"], 1.0, 1.0, 0.0)
        eventFrame:UnregisterEvent("ADDON_LOADED")
        return
    end 
end)

-- ================ SLASH COMMANDS/TESTS ================
function auto:enumSets()
    local sets = enumSetNames()
    for i = 1, #sets do
        auto:postMsg(string.format("%s\n", sets[1]))
    end
end

function auto:getEquippedSet()
    local setName, setId, isEquipped = getEquippedSet()
    return setName, setId, isEquipped
end

function auto:set(setName)
    local result = equipSetByName(setName)
    result = C_EquipmentSet.UseEquipmentSet(setId)
    if not result[1] then auto:postResult(result) end
end
