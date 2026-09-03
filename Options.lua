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



--[[ 

Rough Outline of what is presented to the player by the Options GUI
User Message:

    Right Click the set to be equipped when entering a non-rest-area 
    (or leaving a rest area) Left Click the set to be equipped when 
    entering a rest-area (or leaving a non-rest area)

    [icon 1]    [icon 2]   [icon 3]   [icon 4] 

NOTE: When we implement Riding sets, we can have the user shift-left-click for the riding set

to be continued once the equip code is complete and working, for now just a placeholder

 ]]

-----------------------------------------------------------------
-- Loaded Flag
-----------------------------------------------------------------
AutoEquip.Options.loaded = true
if core:debuggingIsEnabled() then
    local isLoadedStr = string.format("%s loaded", Filename)
    print(isLoadedStr)
end
