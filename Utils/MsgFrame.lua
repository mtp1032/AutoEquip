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
local frames = AutoEquip.Frames

local FAILURE = false

local frameTitle = L["USER_MSG_FRAME"]
local infoMsgFrame = frames:createMsgFrame( frameTitle)

local frameTitle = string.format("ERROR: AutoEquip (V 1.0.0)" )
local errorMsgFrame = frames:createErrorMsgFrame(frameTitle)

function mf:getInfoMsgFrame()
	return infoMsgFrame
end
function mf:showInfoFrame()
	frames:showFrame( infoMsgFrame )
end
function mf:eraseText()  
	frames:clearFrame( infoMsgFrame )
end
function mf:hideInfoFrame()
	frames:hideFrame( infoMsgFrame )
end
function mf:hideMeter()
	frames:hideMeter( infoMsgFrame )
end
function mf:postMsg( msg )
	infoMsgFrame.Text:Insert( msg )
end
function mf:postResult( result )

	if result[1] ~= FAILURE then return end
	
	local resultString = string.format("[FAILURE] %s\n%s", result[2], result[3] )
	errorMsgFrame.Text:Insert( resultString )
	errorMsgFrame:Show()
end
function mf:clearText()
	frames:clearFrameText()
end

