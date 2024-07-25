--------------------------------------------------------------------------------------
-- MsgFrame.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local _, AutoEquip = ... 
AutoEquip.MsgFrame = {}
auto = AutoEquip.MsgFrame
local L = AutoEquip.L
local dbg = equipdbg

local FAILURE = enus.FAILURE

local frameTitle = L["USER_MSG_FRAME"]
local msgFrame = frames:createMsgFrame( frameTitle)

local frameTitle = string.format("ERROR: AutoEquip (V 1.0.0)" )
local errorMsgFrame = frames:createErrorMsgFrame(frameTitle)

function auto:getMsgFrame()
	return msgFrame
end
function auto:showFrame()
	frames:showFrame( msgFrame )
end
function auto:eraseText()  
	frames:clearFrame( msgFrame )
end
function auto:hideFrame()
	frames:hideFrame( msgFrame )
end
function auto:hideMeter()
	frames:hideMeter( msgFrame )
end
function auto:showMeter()
    if errorMsgFrame == nil then 
        return
	end
	if errorMsgFrame:IsVisible() == false then
		errorMsgFrame:Show()
	end
end
function auto:postMsg( msg )
	frames:showFrame( msgFrame )
	msgFrame.Text:Insert( msg )
end
function auto:postErrorMsg( msg )
	frames:showFrame( errorMsgFrame )
	errorMsgFrame.Text:Insert( msg )
end
function auto:postResult( result )

	if result[1] ~= FAILURE then return end
	
	local resultString = string.format("[FAILURE] %s\n%s", result[2], result[3] )
	errorMsgFrame.Text:Insert( resultString )
	errorMsgFrame:Show()
end
function auto:clearText()
	fm:clearFrameText()
end

local fileName = "MsgFrame.lua"
if dbg:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( string.format("%s loaded", fileName), 1.0, 1.0, 0.0 )
end

