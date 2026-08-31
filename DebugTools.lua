AutoEquip = AutoEquip or {}
if not AutoEquip.enUS.loaded then
	DEFAULT_CHAT_FRAME:AddMessage("enUS.lua failed to load", 1, 0, 0)
    return
end
AutoEquip.DebugTools = {}

local core = AutoEquip.Core or {}
local dbg = AutoEquip.DebugTools or {}
local L = AutoEquip.L or {}
-- ================================================================
-- Internal Helper
-- -- ================================================================
-- -- Public Debug Functions
-- -- ================================================================
function dbg:prefix(stackTrace)
    stackTrace = stackTrace or debugstack(2)
    
    -- Extract the relevant part of the stack trace (filename and line number)
    local fileName, lineNumber = stackTrace:match("[\\/]([^\\/:]+):(%d+)")
    if not fileName or not lineNumber then
        return "[Unknown:0] "
    end

    -- Remove any trailing unwanted characters (e.g., `"]`, `*]`, `"`) from the filename
    fileName = fileName:gsub("[%]*\"]", "")

    -- Create the prefix with file name and line number, correctly formatted
    -- local prefix = string.format("[%s:%d] ", fileName, tonumber(lineNumber))
        local prefix = string.format("[%s:%d] ", fileName, tonumber(lineNumber))
        -- DEFAULT_CHAT_FRAME:AddMessage(prefix)
    return prefix
end
function dbg:print(...)
    local prefix = dbg:prefix(debugstack(2))

    -- Convert all arguments to strings and concatenate them with a space delimiter
    local args = {...}
    for i, v in ipairs(args) do
        args[i] = tostring(v)
    end

    prefix = string.format("|cffff9900%s|r", prefix)
    local output = prefix .. table.concat(args, " ")

    -- Directly call the global print function
    DEFAULT_CHAT_FRAME:AddMessage(output)
end

-- Quick toggle helpers
function dbg:enable()
    core:enableDebugging()
end

function dbg:disable()
    core:disableDebugging()
end

-- ================================================================
-- Load Confirmation
-- ================================================================
AutoEquip.DebugTools.loaded = true
if core:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage("DebugTools.lua loaded", 0, 1, 0 )
end
