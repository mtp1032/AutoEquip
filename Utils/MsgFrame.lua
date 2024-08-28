--------------------------------------------------------------------------------------
-- MsgFrame.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ... 

AutoEquip = AutoEquip or {}
AutoEquip.MsgFrame = {}

local L = AutoEquip.Locales
local mf = AutoEquip.MsgFrame
local dbg       = AutoEquip.Debug	-- use for error reporting services
local frames = AutoEquip.Frames

local FAILURE = false

local infoMsgFrame = frames:createMsgFrame( L["USER_INFO_FRAME"] )

local errorMsgFrame = frames:createErrorMsgFrame( L["USER_ERROR_FRAME"] )

function mf:postMsg( msg )
	infoMsgFrame.Text:Insert( msg )
	infoMsgFrame:Show()
end
function mf:postResult( result )

	if result[1] ~= FAILURE then return end
	
	local resultString = string.format("%s %s\n", result[3], result[2] )
	errorMsgFrame.Text:Insert( resultString )
	errorMsgFrame:Show()
end

local fileName = "MsgFrame.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("%s loaded.", fileName ), 1,1,1 )
end

