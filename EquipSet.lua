-----------------------------------------------------------------
-- File: EquipSet.lua
--
-- Provides equipment-set functionality for AutoEquip.
-- AutoEquip equips configured equipment sets when the player's
-- resting state changes.
-----------------------------------------------------------------

local _, AutoEquip = ...

local fileName = "EquipSet.lua"

if not AutoEquip.Core or not AutoEquip.Core.loaded then
    print("Core.lua failed to load")
    return
end

local core = AutoEquip.Core
local dbg = AutoEquip.DebugTools

local equipSet = {}
AutoEquip.EquipSet = equipSet

local savedVariables

-----------------------------------------------------------------
-- Private functions
-----------------------------------------------------------------

local function isSetEquipped(setId)
    if not setId then
        return false
    end

    local _, _, _, isEquipped =
        C_EquipmentSet.GetEquipmentSetInfo(setId)

    return isEquipped
end

local function equipSetById(setId)
    if not setId then
        return
    end

    if isSetEquipped(setId) then
        return
    end

    C_EquipmentSet.UseEquipmentSet(setId)
end

-----------------------------------------------------------------
-- Gameplay events
-----------------------------------------------------------------

local eventFrame = CreateFrame("Frame")

eventFrame:SetScript(
    "OnEvent",
    function(_, event)
        if event == "PLAYER_UPDATE_RESTING" then
            equipSet:onPlayerUpdateResting()
        end
    end
)

-----------------------------------------------------------------
-- Public functions
-----------------------------------------------------------------

function equipSet:setRestingSetId(setId)
    savedVariables.restingSetId = setId
end

function equipSet:setNonRestingSetId(setId)
    savedVariables.nonRestingSetId = setId
end

function equipSet:getRestingSetId()
    return savedVariables.restingSetId
end

function equipSet:getNonRestingSetId()
    return savedVariables.nonRestingSetId
end

function equipSet:initialize()
    if self.initialized then
        return
    end

    if not core.initialized then
        error(
            "EquipSet cannot initialize before Core initialization."
        )
    end

    local database = core:getSavedVariables()

    if not database then
        error(
            "EquipSet could not access AutoEquip SavedVariables."
        )
    end

    savedVariables = database.equipmentSets

    eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")

    self.initialized = true

    if dbg and dbg.loaded then
        dbg:print(fileName .. " initialized")
    end
end

function equipSet:onPlayerUpdateResting()
    if not self.initialized then
        return
    end

    if IsResting() then
        equipSetById(savedVariables.restingSetId)
    else
        equipSetById(savedVariables.nonRestingSetId)
    end
end

-- Returns the player's equipment sets for use by modules such
-- as Options. Each entry contains the set name, ID, and icon.
function equipSet:getEquipmentSets()
    local equipmentSets = {}
    local equipmentSetIds =
        C_EquipmentSet.GetEquipmentSetIDs()

    for _, equipmentSetId in ipairs(equipmentSetIds) do
        local setName, iconFileId, setId =
            C_EquipmentSet.GetEquipmentSetInfo(
                equipmentSetId
            )

        equipmentSets[#equipmentSets + 1] = {
            name = setName,
            id = setId,
            icon = iconFileId,
        }
    end

    return equipmentSets
end

-----------------------------------------------------------------
-- Module state
-----------------------------------------------------------------

equipSet.loaded = true
equipSet.initialized = false

if core:isDebuggingEnabled() then
    print(fileName .. " loaded")
end