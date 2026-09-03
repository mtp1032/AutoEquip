-----------------------------------------------------------------
-- File: EquipSet.lua
-----------------------------------------------------------------
local ADDON_NAME, _ = ...
local Filename = "EquipSet.lua"

AutoEquip = AutoEquip or {}
AutoEquip.EquipSet = AutoEquip.EquipSet or {}
AutoEquip.Options = AutoEquip.Options or {}

if not AutoEquip.MinimapButton.loaded then
    local failMsg = string.format("%s failed to load", "MinimapButton.lua" )
    print(failMsg)
    return
end

local core = AutoEquip.Core
local dbg = AutoEquip.DebugTools

local config

local function getEquipmentSetIdByName(name)
    local ids = C_EquipmentSet.GetEquipmentSetIDs()
    for _, id in ipairs(ids) do
        local n = C_EquipmentSet.GetEquipmentSetInfo(id)
        if n == name then
            return id
        end
    end
    return nil
end

local function equipSetByName(name)
    if not name then return end
    local id = getEquipmentSetIdByName(name)
    if id then
        C_EquipmentSet.UseEquipmentSet(id)
    end
end

function AutoEquip.EquipSet:Initialize()
    -- Bind saved variables
    AutoEquip_SavedVars = AutoEquip_SavedVars or {}
    AutoEquip_SavedVars.config = AutoEquip_SavedVars.config or {
        rest_area_set = nil,
        non_rest_area_set = nil,
    }

    config = AutoEquip_SavedVars.config
    self.config = config
    self.loaded = true
end

-- Called when entering a rest area
function AutoEquip.EquipSet:OnEnterRestArea()
    equipSetByName(config.rest_area_set)
end

-- Called when leaving a rest area
function AutoEquip.EquipSet:OnLeaveRestArea()
    equipSetByName(config.non_rest_area_set)
end

-----------------------------------------------
-- File: EquipSet.lua
AutoEquip = AutoEquip or {}
AutoEquip.EquipSet = AutoEquip.EquipSet or {}

local config

local function getEquipmentSetIdByName(name)
    local ids = C_EquipmentSet.GetEquipmentSetIDs()
    for _, id in ipairs(ids) do
        local n = C_EquipmentSet.GetEquipmentSetInfo(id)
        if n == name then
            return id
        end
    end
    return nil
end

local function equipSetByName(name)
    if not name then return end
    local id = getEquipmentSetIdByName(name)
    if id then
        C_EquipmentSet.UseEquipmentSet(id)
    end
end

function AutoEquip.EquipSet:Initialize()
    -- Bind saved variables
    AutoEquip_SavedVars = AutoEquip_SavedVars or {}
    AutoEquip_SavedVars.config = AutoEquip_SavedVars.config or {
        rest_area_set = nil,
        non_rest_area_set = nil,
    }

    config = AutoEquip_SavedVars.config
    self.config = config
    self.loaded = true
end

-- Called when entering a rest area
function AutoEquip.EquipSet:OnEnterRestArea() 
    equipSetByName(config.rest_area_set)
end

-- Called when leaving a rest area
function AutoEquip.EquipSet:OnLeaveRestArea()
    equipSetByName(config.non_rest_area_set)
end

----------------------------------

function AutoEquip.EquipSet:GetEquipmentSetNameTable()
    local ids = C_EquipmentSet.GetEquipmentSetIDs()
    local sets = {}

    for _, id in ipairs(ids) do
        local name, icon = C_EquipmentSet.GetEquipmentSetInfo(id)
        if name and icon then
            table.insert(sets, { name = name, icon = icon })
        end
    end

    return sets
end
-- 
AutoEquip.EquipSet.loaded = true
if core:debuggingIsEnabled() then
    local isLoadedStr = string.format("%s loaded", Filename)
    print(isLoadedStr)
end

