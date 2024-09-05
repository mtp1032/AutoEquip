--------------------------------------------------------------------------------------
-- MsgFrame.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ... 

AutoEquip = AutoEquip or {}
AutoEquip.MsgFrame = {}

local mf 		= AutoEquip.MsgFrame
local dbg       = AutoEquip.Debug	-- use for error reporting services
local frames 	= AutoEquip.Frames
local L = AutoEquip.Locales


local FAILURE 		= false
local infoMsgFrame	= frames:createMsgFrame( L["TITLE_INFO_MSG_FRAME"] )
local errorMsgFrame = frames:createMsgFrame( L["TITLE_ERROR_MSG_FRAME"] )
local helpMsgFrame 	= frames:createHelpFrame( L["TITLE_HELP_MSG_FRAME"] )

infoMsgFrame:Hide()
errorMsgFrame:Hide()
helpMsgFrame:Hide()

function mf:postMsg( msg )
	msg = string.format("%s\n", msg )
	infoMsgFrame.Text:Insert( msg )
	infoMsgFrame:Show()
end
function mf:postResult( result )
	if result[1] ~= FAILURE then return end
	
	local resultString = string.format("%s %s\n", result[3], result[2] )
	errorMsgFrame.Text:Insert( resultString )
	errorMsgFrame:Show()
end

function mf:helpFrame()
	helpMsgFrame:Show()
end


local fileName = "MsgFrame.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("[%s] %s loaded.", ADDON_NAME, fileName ), 1,1,1 )
end

