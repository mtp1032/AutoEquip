AutoEquip = AutoEquip or {}
if not AutoEquip.DebugTools.loaded  then
    DEFAULT_CHAT_FRAME:AddMessage("DebugTools.lua not loaded", 0, 1, 0)
    return
end

local core  = AutoEquip.Core
local dbg   = AutoEquip.DebugTools
local L     = AutoEquip.enUS.L 

local addonName = core:getAddonInfo()
local eventFrame = CreateFrame("Frame")

----------------- SAVED VARIABLES AUTOEQUIP_SAVED_DB -----------------
-- QUESTING_SET_TABLE, RESTING_SET_TABLE
questingSetTable = {
    previousSetId = nil,
    setId = nil
}
restingSetTable = {
    previousSetId = nil,
    setId = nil
}
------------------- AUTOEQUIP CORE LOGIC ------------------------
-- Helper function to get the equipment set ID by name
-- USAGE: local setId, errorMessage = getArmorSetId("EquipmentSetName")
--        if not setId then dbg:print(errorMessage) end
local function getArmorSetId( setName )
    local errorMessage = nil
    local setId = C_EquipmentSet.GetEquipmentSetID(setName)
    if not setId then
        errorMessage = L["UNKNOWN_EQUIPMENT_SET_NAME"]
    end
    return setId, errorMessage
end

local function getEquippedSetName( setId )
    local errorMessage = nil
    local setName = C_EquipmentSet.GetEquipmentSetInfo(setId)
    if not setName then
        errorMessage = L["UNKNOWN_EQUIPMENT_SET_ID"]
    end
    return setName, errorMessage
end

-- Helper function to get the ID of the currently equipped equipment set
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
-- Helper function to check if the armor set specified by the setId is currently equipped
local function isSetEquipped( setId )
    local _, _, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setId)
    if isEquipped == nil then
        errorMessage = L["UNKNOWN_EQUIPMENT_SET_ID"]
        return
    end
    return isEquipped
end

-- Equip the riding set
local function equipArmorSet( setId )
  C_EquipmentSet.UseEquipmentSet(setId)
end

-- When the PLAYER_UPDATE_RESTING event is fired, check if the player is resting or not. 
-- If resting, equip the heirloom set. If not resting, restore the previous set.

local function UpdateRestingState()
    local heirloomSetId = restingSetTable.setId
    if IsResting() and not isSetEquipped( heirloomSetId ) then
        dbg:print("Entered Rest Area, equip Heirloom Set")
        restingSetTable.previousHeirloomSetId = getEquippedSetId()
        equipArmorSet( heirloomSetId )
    
    elseif not IsResting() and isSetEquipped( heirloomSetId ) and restingSetTable.previousHeirloomSetId then
        dbg:print("Left Rest Area, restore previous Set")
        equipArmorSet( restingSetTable.previousHeirloomSetId )
        restingSetTable.previousHeirloomSetId = nil
    end
end

-- Events that detect mounting/dismounting
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")

-- Event dispatcher
eventFrame:SetScript("OnEvent",
function(self, event, ...)
    local arg = {...}

    if event == "ADDON_LOADED" and arg[1] == addonName then
        DEFAULT_CHAT_FRAME:AddMessage(L["ADDON_NAME_AND_VERSION"], 0, 1, 1)

        restingSetTable.setId, errorMsg = getArmorSetId( "LOOMS" )
        if not restingSetTable.setId then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("%s %s", dbg:prefix(), errorMsg ))
            return
        end
        questingSetTable.setId, errorMsg = getArmorSetId( "PROT" )
        if not restingSetTable.setId then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("%s %s", dbg:prefix(), errorMsg ))
            return
        end

        
        eventFrame:UnregisterEvent("ADDON_LOADED")
        return
    end

        -- handling this event is what the addon is all about
    if event == "PLAYER_UPDATE_RESTING" then
        UpdateRestingState()
        return
    end
end)


AutoEquip.loaded = true
if core:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage("AutoEquip.lua loaded", 0, 1, 0 )
end

