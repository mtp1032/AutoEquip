-----------------------------------------------------------------
-- File: DebugTools.lua
-----------------------------------------------------------------

AutoEquip = AutoEquip or {}
AutoEquip.DebugTools = AutoEquip.DebugTools or {}

if not AutoEquip.enUS then
    print("|cffff0000[AutoEquip]|r enUS.lua failed to load")
    return
end

local core = AutoEquip.Core
local L = AutoEquip.enUS.L
local dbg = AutoEquip.DebugTools

-- ================================================================
-- Internal Helper
-- ================================================================
function dbg:prefix(stackTrace)
    stackTrace = stackTrace or debugstack(3)

    local fileName, lineNumber = stackTrace:match("[\\/]([^\\/:]+):(%d+)")
    if not fileName or not lineNumber then
        return "[Unknown:0] "
    end

    return string.format("[%s:%d] ", fileName, tonumber(lineNumber))
end

-- ================================================================
-- Public Debug Functions
-- ================================================================
function dbg:print(...)
    if not core:debuggingIsEnabled() then return end

    local prefix = dbg:prefix(debugstack(3))

    local args = {...}
    for i, v in ipairs(args) do
        args[i] = tostring(v)
    end

    local output = prefix .. table.concat(args, " ")

    AutoEquip.DebugWindow:Append(output)
end

function dbg:enable()
    core:enableDebugging()
    return true
end

function dbg:disable()
    core:disableDebugging()
    return false
end

-- ================================================================
-- Load Confirmation
-- ================================================================
AutoEquip.DebugTools.loaded = true

if core:debuggingIsEnabled() then
    print("|cff00ff00[AutoEquip]|r DebugTools.lua loaded")
end
