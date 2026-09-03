-----------------------------------------------------------------
-- File: Options.lua
-----------------------------------------------------------------
ADDON_NAME, _ = ...
local Filename = "Options.lua"

AutoEquip = AutoEquip or {}
AutoEquip.Options = AutoEquip.Options or {} 

if not AutoEquip.EquipSet.loaded then
    local failMsg = string.format("%s failed to load", "EquipSet.lua" )
    print(failMsg)
    return
end

-- Shortcut references
local core  = AutoEquip.Core 
local dbg   = AutoEquip.DebugTools
local L     = AutoEquip.enUS.L
local equip = AutoEquip.EquipSet


-- to be continued once the equip code is complete and working, for now just a placeholder

-----------------------------------------------------------------
-- Loaded Flag
-----------------------------------------------------------------
AutoEquip.Options.loaded = true
if core:debuggingIsEnabled() then
    local isLoadedStr = string.format("%s loaded", Filename)
    print(isLoadedStr)
end
