--------------------------------------------------------------------------------------
-- Debug.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------

local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.Debug = {}	  
local dbg = AutoEquip.Debug	-- use for error reporting services

local EMPTY_STR 	= ""
local SUCCESS	= true
local FAILURE	= false

local DEBUG_ENABLED = true
---------------------------------------------------------------------------------------------------
--                      PUBLIC/EXPORTED FUNCTIONS
----------------------------------------------------------------------------------------------------
function dbg:debuggingIsEnabled()
    return DEBUG_ENABLED
end
function dbg:enableDebugging()
    DEBUG_ENABLED = true
end
function dbg:disableDebugging()
    DEBUG_ENABLED = false
end

function dbg:simpleStackTrace( stackTrace )
	if stackTrace == nil then stackTrace = debugstack(2) end

	local str = string.sub( stackTrace, 28 )
	local pieces = {strsplit( ":", str, 5 )}
	local len = strlen( pieces[1])
	dir = string.sub( pieces[1], 1, len - 2 )
	local simple = string.format("%s]%d", dir, pieces[2])
	return simple
end
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
function dbg:setResult( reason, location )
	return 	{ FAILURE, reason, location }
end

local fileName = "Debug.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("%s loaded.", fileName ), 1,1,1 )
end

