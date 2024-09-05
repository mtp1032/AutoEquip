--------------------------------------------------------------------------------------
-- Debug.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------

local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.Debug = {}	  
local dbg = AutoEquip.Debug	-- use for error reporting services
local L = AutoEquip.Locales

local EMPTY_STR 	= ""
local SUCCESS	= true
local FAILURE	= false

local DEBUG_ENABLED = true

---------------------------------------------------------------------------------------------------
--                      PUBLIC/EXPORTED FUNCTIONS
----------------------------------------------------------------------------------------------------
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
    local prefix = string.format("[%s:%d] ", fileName, tonumber(lineNumber))
    return prefix
end
function dbg:print(...)
    local prefix = dbg:prefix(debugstack(2))

    -- Convert all arguments to strings and concatenate them with a space delimiter
    local args = {...}
    for i, v in ipairs(args) do
        args[i] = tostring(v)
    end

    local output = prefix .. table.concat(args, " ")

    -- Directly call the global print function
    print(output)
end
function dbg:debuggingIsEnabled()
    return DEBUG_ENABLED
end
function dbg:enable()
    DEBUG_ENABLED = true
    autoEquip_Saved_Debug = DEBUG_ENABLED
    local msg = string.format( L["DEBUGGING_ENABLED"], ADDON_NAME)
    DEFAULT_CHAT_FRAME:AddMessage( msg, 0,1,0 )
end
function dbg:disable()
    DEBUG_ENABLED = false
    autoEquip_Saved_Debug = DEBUG_ENABLED
    local msg = string.format( L["DEBUGGING_DISABLED"], ADDON_NAME)
    DEFAULT_CHAT_FRAME:AddMessage( msg, 0,1,0 )  
end
function dbg:setResult( reason, location )
	return 	{ FAILURE, reason, location }
end

local fileName = "Debug.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("[%s] %s loaded.", ADDON_NAME,fileName ), 1,1,1 )
end

