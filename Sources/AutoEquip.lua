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
local dbg       = AutoEquip.Debug	-- use for error reporting services
local mf        = AutoEquip.MsgFrame
local frames    = AutoEquip.Frames

local EMPTY_STR = ""
local SUCCESS   = true

-- Initialize the saved variables
if autoEquip_Resting_SetId == nil then
    autoEquip_Resting_SetId = nil
end

if autoEquip_Saved_SetId == nil then
    autoEquip_Saved_SetId = nil
end

-- This function is called on the ADDON_LOADED event
local function initializeSavedVariables()
    if autoEquip_Resting_SetId == nil then
        autoEquip_Resting_SetId = nil
    end
    if autoEquip_Saved_SetId == nil then
        autoEquip_Saved_SetId = nil
    end
end

-- =========================================================================
---                         services
-- =========================================================================

-- return true/false if player is eligible to use equipment sets
local function canUseEquipmentSets()
    local canUse = true
    local reason = nil
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

    if UnitLevel("Player") < 10 then
        canUse = false
        reason = string.format( L["LEVEL_REQUIREMENT"], UnitName("Player"))
        result = dbg:setResult( reason, dbg:prefix() )
        return canUse, result
    end

    local numEquipSets = C_EquipmentSet.GetNumEquipmentSets()
    if numEquipSets == 0 then
        canUse = false
        local reason = string.format( L["EQUIPMENT_SETS_NOT_DEFINED"], UnitName("Player"))
        result = dbg:setResult( reason, dbg:prefix() )
        return canUse, result
    end

    -- check whether one or more equipment sets are useable
    if not C_EquipmentSet.CanUseEquipmentSets() then
        canUse = false
        reason = L["EQUIPMENT_SETS_UNAVAILABLE"]
        result = dbg:setResult( reason, dbg:prefix() )
        return canUse, result
    end
    return canUse, result
end

-- returns a table of equipment set names
local function enumSetNames()
    local setNames = {}

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        setNames[i] = C_EquipmentSet.GetEquipmentSetInfo( setIds[i] )        
    end
    return setNames
end
-- returns the setName, isEquipped, and result.
local function getSetNameByID( setId )
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local setName = nil
    local isEquipped = false

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        local setName, _, id, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if setId == id then 
            isEquipped = equipped
            return setName, isEquipped, result
        end
    end
    assert( setName == nil )

    -- We're here because the input setId did not identify any of the player's armor sets.
    local reason = L["EQUIPMENT_SET_NOT_FOUND"]
    result = dbg:setResult( reason, dbg:prefix() )
    return nil, nil, result
end
-- returns the setId, isEquipped, and result
local function getSetIdByName(setName)
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local isEquipped = nil
    local setId = nil

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        local name, _, id, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if name == setName then 
            isEquipped = equipped
            setId = id
            return setId, isEquipped, result
        end
    end
    -- we're here because the player's input armor set name was not found.
    assert( setId == nil )

    local reason = L["EQUIPMENT_SET_NOT_FOUND"]
    result = dbg:setResult( reason, dbg:prefix() )

    return nil, nil, result
end
-- returns isEquipped, result (result is always SUCCESSFUL)
local function setIsEquipped(setId)
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local isEquipped = false
    local setName = nil

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        local _, _, id, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if setId == id then
            isEquipped = equipped
        end
    end
    return isEquipped, result
end
-- return setId, setName. Returns nil if no set is equipped.
local function getEquippedSet()
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    
    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        local setName, _, setId, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if equipped then 
            return setId, setName, result
        end
    end    -- we're here because the player is equipped with an undefined set.
    local reason = L["EQUIPMENT_SET_NOT_FOUND"]
    result = dbg:setResult( reason, dbg:prefix() )
    return nil, nil, result
end

function auto:setRestXpSet( inputXPsetName ) -- Set only via the options menu
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

    local numEquipSets = C_EquipmentSet.GetNumEquipmentSets()
    if numEquipSets == 0 then
        local reason = string.format( L["EQUIPMENT_SETS_NOT_DEFINED"], UnitName("Player"))
        result = dbg:setResult( reason, dbg:prefix() )
        return result
    end

    local canUse, result = canUseEquipmentSets()
    if not result[1] then 
        return result
    end

    local restingSetId, equipped, result = getSetIdByName( inputXPsetName )
    if not result[1] then 
        mf:postResult( result )
        return
    end

    local savedSetId, savedSetName, result = getEquippedSet()
    if not result[1] then
        mf:postResult( result )
        return
    end


    autoEquip_Resting_SetId = restingSetId
    autoEquip_Saved_SetId   = savedSetId

    -- If player is already in a resting zone and his resting set is not equipped,
    -- then equip the resting set.
    if IsResting() then 
        if not setIsEquipped( autoEquip_Resting_SetId ) then
            local successful = C_EquipmentSet.UseEquipmentSet( autoEquip_Resting_SetId )
            if not successful then
                local reason = string.format(L["FAILED_TO_EQUIP_SET"], inputXPsetName)
                local result = dbg:setResult( reason, dbg:prefix() )
                return result
            end
        end
    end
    return result
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
eventFrame:RegisterEvent("UI_ERROR_MESSAGE")
eventFrame:RegisterEvent("UI_INFO_MESSAGE")

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

-- eventFrame:RegisterEvent("UI_ERROR_MESSAGE")

eventFrame:SetScript("OnEvent",
function(self, event, ...)
    local arg = {...}

    if event == "UI_ERROR_MESSAGE" then
        local errorType, message = ...
        dbg:customErrorDisplay( message, errorType )
        return
    end

    if event == "PLAYER_UPDATE_RESTING" then

        local msg = nil
        local color = nil
        local isEquipped = nil
        local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

        local restingSetName, _, result = getSetNameByID( autoEquip_Resting_SetId )
        if not result[1] then
            mf:postResult( result )
            return
        end
        local restingSetId, _, result = getSetIdByName( restingSetName )
        if not result[1] then
            mf:postResult( result )
            return
        end

        local savedSetName, _, result = getSetNameByID( autoEquip_Saved_SetId )
        if not result[1] then
            mf:postResult( result )
            return
        end

        local savedSetId, _, result = getSetIdByName( savedSetName )
        if not result[1] then
            mf:postResult( result )
            return
        end

        if IsResting() then
            color = frames.GREEN
        
            -- Player has entered a resting area. If the player is not wearing
            -- his resting set, then equip it. If he is, do nothing.
            local isEquipped, result = setIsEquipped( restingSetId )
            if not isEquipped then
                local successful = C_EquipmentSet.UseEquipmentSet( restingSetId )
                if not successful then
                    local reason = string.format(L["FAILED_TO_EQUIP_SET"], restingSetName )
                    local result = dbg:setResult( reason, dbg:prefix() )
                    mf:postResult( result )
                    return value
                end
                msg = string.format( L["ENTERED_REST_AREA"], restingSetName)
            end
        else
            color = frames.RED
            -- Player has left the resting zone. Equip the saved set
            local successful = C_EquipmentSet.UseEquipmentSet( savedSetId )
            if not successful then
                local reason = string.format(L["FAILED_TO_EQUIP_SET"], savedSetName )
                local result = dbg:setResult( reason, dbg:prefix() )
                mf:postResult( result )
                return
            end
            msg = string.format( L["LEFT_REST_AREA"], savedSetName )
        end

        frames:notifyEquipmentChange( msg, 3, color )
        if dbg:debuggingIsEnabled() then
            DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0)
        end
        return
    end

    if event == "ADDON_LOADED" and arg[1] == ADDON_NAME then
        initializeSavedVariables()
        -- Unregister the event after initializing
        DEFAULT_CHAT_FRAME:AddMessage(L["ADDON_LOADED_MSG"], 1.0, 1.0, 0.0)
        eventFrame:UnregisterEvent("ADDON_LOADED")
        return
    end 

    if event == "PLAYER_UPDATE_RESTING" then

        local msg = nil
        local color = nil
        local isEquipped = nil
        local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

        local restingSetName, _, result = getSetNameByID( autoEquip_Resting_SetId )
        if not result[1] then
            mf:postResult( result )
            return
        end
        local restingSetId, _, result = getSetIdByName( restingSetName )
        if not result[1] then
            mf:postResult( result )
            return
        end

        local savedSetName, _, result = getSetNameByID( autoEquip_Saved_SetId )
        if not result[1] then
            mf:postResult( result )
            return
        end

        local savedSetId, _, result = getSetIdByName( savedSetName )
        if not result[1] then
            mf:postResult( result )
            return
        end

        if IsResting() then
            color = frames.GREEN
        
            -- Player has entered a resting area. If the player is not wearing
            -- his resting set, then equip it. If he is, do nothing.
            local isEquipped, result = setIsEquipped( restingSetId )
            if not isEquipped then
                local successful = C_EquipmentSet.UseEquipmentSet( restingSetId )
                if not successful then
                    local reason = string.format(L["FAILED_TO_EQUIP_SET"], restingSetName )
                    local result = dbg:setResult( reason, dbg:prefix() )
                    mf:postResult( result )
                    return value
                end
                msg = string.format( L["ENTERED_REST_AREA"], restingSetName)
            end
        else
            color = frames.RED
            -- Player has left the resting zone. Equip the saved set
            local successful = C_EquipmentSet.UseEquipmentSet( savedSetId )
            if not successful then
                local reason = string.format(L["FAILED_TO_EQUIP_SET"], savedSetName )
                local result = dbg:setResult( reason, dbg:prefix() )
                mf:postResult( result )
                return
            end
            msg = string.format( L["LEFT_REST_AREA"], savedSetName )
        end

        frames:notifyEquipmentChange( msg, 3, color )
        if dbg:debuggingIsEnabled() then
            DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0)
        end
    end
end)

-- ================ SLASH COMMANDS/TESTS ================
function auto:setsAreAvailable()
    local areAvailable = true
    local result = { SUCCESS, EMPTY_STR, EMPTY_STR}

    if UnitLevel("Player") < 10 then
        local reason = string.format( L["LEVEL_REQUIREMENT"], UnitName("Player"))
        result = dbg:setResult( reason, dbg:prefix() )
        areAvailable = false
        return areAvailable, result
    end
    -- check whether one or more equipment sets are useable
    if not C_EquipmentSet.CanUseEquipmentSets() then
        local reason = L["INVALID_EQUIPMENT_SET"]
        result = dbg:setResult( reason, dbg:prefix() )
        areAvailable = false
        return areAvailable, result
    end

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()

    if setIds == nil or #setIds == 0 then
        local reason = string.format( L["EQUIPMENT_SETS_NOT_DEFINED"], UnitName("Player"))
        result = dbg:setResult( reason, dbg:prefix() )
        areAvailable = false
        return areAvailable, result
    end
    return areAvailable, result
end
function auto:enumSets()
    local sets = enumSetNames()
    for i = 1, #sets do
        mf:postMsg(string.format("%s\n", sets[1]))
    end
end
function auto:getEquippedSet()
    local setId, setName = getEquippedSet()
    return setId, setName
end

local fileName = "AutoEquip.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("%s loaded.", fileName ), 1,1,1 )
end

