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

---------------------------------------------------------------------------------------------------
--                      PUBLIC/EXPORTED FUNCTIONS
----------------------------------------------------------------------------------------------------
function dbg:simpleStackTrace( stackTrace )
	if stackTrace == nil then stackTrace = debugstack(2) end

	local str = string.sub( stackTrace, 28 )
	local pieces = {strsplit( ":", str, 5 )}
	local len = strlen( pieces[1])
	dir = string.sub( pieces[1], 1, len - 2 )
	local simple = string.format("%s]%d", dir, pieces[2])
	return simple
end
function dbg:prefix( stackTrace )
	if stackTrace == nil then stackTrace = debugstack(2) end
	-- print( stackTrace )

	local pieces = {strsplit( ":", stackTrace, 5 )}
	local segments = {strsplit( "\\", pieces[1], 5 )}

	local fileName = segments[#segments]
	
	local strLen = string.len( fileName )
	local fileName = string.sub( fileName, 1, strLen - 2 )
	local names = strsplittable( "\/", fileName )
	local lineNumber = tonumber(pieces[2])
	local location = string.format("[%s:%d] ", names[#names], lineNumber)
	return location
end
function dbg:print( msg )
	local fileAndLine = dbg:prefix( debugstack(2) )
	-- print(fileAndLine .. " " .. msg)
	local str = msg
	if str then
		str = string.format("%s %s", fileAndLine, str )
	else
		str = fileAndLine
	end
	DEFAULT_CHAT_FRAME:AddMessage( str, 0.0, 1.0, 1.0 )
end	
function dbg:setResult( errMsg, stackTrace )
	local result = {FAILURE, EMPTY_STR, EMPTY_STR }
	return 	{ FAILURE, errMsg, stackTrace }

end

