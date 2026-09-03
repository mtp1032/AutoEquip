-----------------------------------------------------------------
-- File: EquipSet.lua
--
-- BACKGROUND: The purpose of this file is to provide the functionality for the
-- AutoEquip Addon. The Addon is designed to automatically equip a user's
-- equipment sets based on their current location and resting status.
--
-- in practice, players use this set to equip armor sets that contain one or more
-- HEIRLOOM items when entering a rest area.
-----------------------------------------------------------------
local ADDON_NAME, _ = ...
local Filename = "EquipSet.lua"

AutoEquip = AutoEquip or {}
AutoEquip.EquipSet = AutoEquip.EquipSet or {}

if not AutoEquip.MinimapButton.loaded then
    local failMsg = string.format("%s failed to load", "MinimapButton.lua" )
    print(failMsg)
    return
end

local core = AutoEquip.Core
local dbg = AutoEquip.DebugTools

-- Returns the name of the currently equipped set. Note, users will have sets that
-- are not rest- or non-rest-area sets. In other words, this function will return 
-- the name of the currently equipped set, even if it is not one of the sets that 
-- the user has designated for rest or non-rest areas.
local function getEquippedSetId()
    local setId = nil
    local isEquipped = nil

    local tableIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #tableIds do
        local _, _, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setId)
        if isEquipped then
            return setId, isEquipped
        end
    end
    return setId, isEquipped
end

-- USAGE: test whether a specific set (the rest- or non-rest-area set) is currently 
-- equipped. This function is used first, to equip a set according to the rest state
-- of the player.-- 
local function isSetEquipped(setId)
    local _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setId)
    return isEquipped
end

------------ PUBLIC FUNCTIONS ---------------------------------------------------
-- Needs comment. 
function AutoEquip.EquipSet:Initialize()
    -- Bind saved variables
    AutoEquip_SavedVars = AutoEquip_SavedVars or {}
    AutoEquip_SavedVars.config = AutoEquip_SavedVars.config or {
        rest_area_set = nil,
        non_rest_area_set = nil,
    }

    CONFIG = AutoEquip_SavedVars.config
    self.config = config
    self.loaded = true
end

-- USAGE: 
-- Returns a table, each element of which contains a set's name, Id, and iconTexture.The 
-- The table is used by the Options module to display the icons from which the user can 
-- choose for his resting and non-resting sets.
function getEquipmentSetInfo(name)
    local setName, setId, iconTexture = nil, nil, nil
    local setInfo = {}

    local Ids = C_EquipmentSet.GetEquipmentSetIDs()
    for _, id in ipairs(Ids) do
        local setName, setId, _, iconTexture = C_EquipmentSet.GetEquipmentSetInfo(id)
        table.insert(setInfo, { name = setName, id = setId, icon = iconTexture })
    end
    return setInfo
end

-- This is the heart of the Addon. It is called when the PLAYER_UPDATE_RESTING fires.
-- The equipmentSetIds are space fillers, for the moment. They well ultimately be 
-- replaced with the equipment set Ids from the AUTOEQUIP_SAVED_VARS_DB.
function AutoEquip.EquipSet:onPlayerUpdateResting()

    -- Player has entered a rest area.
    if IsResting() and not isSetEquipped(rest_area_set) then
        C_EquipmentSet.UseEquipmentSet(rest_area_set)
    end
    
    -- Player has left a rest area.
    if not IsResting() and not isSetEquipped(non_rest_area_set) then
        C_EquipmentSet.UseEquipmentSet(non_rest_area_set)
    end
end

AutoEquip.EquipSet.loaded = true
if core:debuggingIsEnabled() then
    print(fileName .. " loaded")
end

