-----------------------------------------------------------------
-- File: EquipSet.lua
-----------------------------------------------------------------
AutoEquip = AutoEquip or {}
AutoEquip.EquipSet = AutoEquip.EquipSet or {}

-- Ensure DebugTools loaded
if not AutoEquip.MinimapButton.loaded then
    print("MinimapButton.lua not loaded")
    return
end

local core  = AutoEquip.Core
local dbg   = AutoEquip.DebugTools
local L     = AutoEquip.enUS.L
local equip = AutoEquip.EquipSet


-- ADDON_NAME from environment is canonical for ADDON_LOADED
local ADDON_NAME = ...

local eventFrame = CreateFrame("Frame")

-----------------------------------------------------------------
-- SAVED VARIABLES STRUCTURE
-----------------------------------------------------------------

AUTOEQUIP_SAVED_VARS_DB = AUTOEQUIP_SAVED_VARS_DB or {}

AUTOEQUIP_SAVED_VARS_DB.config = AUTOEQUIP_SAVED_VARS_DB.config or {
    restingSetName  = nil,
    questingSetName = nil,
    ridingSetName   = nil, -- future
}

AUTOEQUIP_SAVED_VARS_DB.state = AUTOEQUIP_SAVED_VARS_DB.state or {
    resting = { previousSetId = nil },
    questing = { previousSetId = nil },
    riding = { previousSetId = nil },
}

local config = AUTOEQUIP_SAVED_VARS_DB.config
local state  = AUTOEQUIP_SAVED_VARS_DB.state

-----------------------------------------------------------------
-- CORE LOGIC HELPERS
-----------------------------------------------------------------

local function getEquipmentSetId(setName)
    local id = C_EquipmentSet.GetEquipmentSetID(setName)
    if not id then
        return nil, L["UNKNOWN_EQUIPMENT_SET_NAME"]
    end
    return id, nil
end

local function getEquippedSetId()
    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        local _, _, _, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if equipped then
            return setIds[i]
        end
    end
    return nil
end

local function isSetEquipped(setId)
    local _, _, _, equipped = C_EquipmentSet.GetEquipmentSetInfo(setId)
    if equipped == nil then
        return nil, L["UNKNOWN_EQUIPMENT_SET_ID"]
    end
    return equipped, nil
end

local function equipSet(setId)
    if not setId then return end
    C_EquipmentSet.UseEquipmentSet(setId)
end

-----------------------------------------------------------------
-- RESTING LOGIC
-----------------------------------------------------------------

local function UpdateRestingState()
    local restingName = config.restingSetName
    if not restingName then
        dbg:print("No resting set configured.")
        return
    end

    local restingId, err = getEquipmentSetId(restingName)
    if err then
        dbg:print(err)
        return
    end

    local equipped, err2 = isSetEquipped(restingId)
    if err2 then
        dbg:print(err2)
        return
    end

    if IsResting() and not equipped then
        dbg:print("Entered Rest Area → equipping resting set:", restingName)
        state.resting.previousSetId = getEquippedSetId()
        equipSet(restingId)

    elseif not IsResting() and equipped and state.resting.previousSetId then
        dbg:print("Left Rest Area → restoring previous set")
        equipSet(state.resting.previousSetId)
        state.resting.previousSetId = nil
    end
end

-----------------------------------------------------------------
-- PUBLIC CONFIG API (called by future options UI)
-----------------------------------------------------------------

function equip:initializeConfig(restingSetName, questingSetName)
    -- Validate resting set
    if restingSetName then
        local id, err = getEquipmentSetId(restingSetName)
        if not id then
            return false, err
        end
        config.restingSetName = restingSetName
        state.resting.previousSetId = nil
    end

    -- Validate questing set
    if questingSetName then
        local id, err = getEquipmentSetId(questingSetName)
        if not id then
            return false, err
        end
        config.questingSetName = questingSetName
        state.questing.previousSetId = nil
    end

    return true
end

-----------------------------------------------------------------
-- EVENT HANDLERS
-----------------------------------------------------------------

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...

    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then

        -- Validate saved config (user may have deleted sets)
        if config.restingSetName then
            local id = C_EquipmentSet.GetEquipmentSetID(config.restingSetName)
            if not id then
                dbg:print( "Resting set no longer exists:", config.restingSetName )
                config.restingSetName = nil
            end
        end

        if config.questingSetName then
            local id = C_EquipmentSet.GetEquipmentSetID(config.questingSetName)
            if not id then
                dbg:print("Questing set no longer exists:", config.questingSetName)
                config.questingSetName = nil
            end
        end

        eventFrame:UnregisterEvent("ADDON_LOADED")
        return
    end
    
    if event == "PLAYER_UPDATE_RESTING" then
        UpdateRestingState()
        return
    end
end)

AutoEquip.EquipSet.loaded = true
if core:debuggingIsEnabled() then
    dbg:print( "EquipSet.lua loaded" )
end
