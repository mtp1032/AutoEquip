--------------------------------------------------------------------------------------
-- MsgFrame.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ... 

AutoEquip = AutoEquip or {}
AutoEquip.MsgFrame = {}
local msgFrame = AutoEquip.MsgFrame
local frames = AutoEquip.Frames

local L = AutoEquip.Locales
local dbg = AutoEquip.Debug

local FAILURE = false

local frameTitle = L["USER_MSG_FRAME"]
local msgFrame = frames:createMsgFrame( frameTitle)

local frameTitle = string.format("ERROR: AutoEquip (V 1.0.0)" )
local errorMsgFrame = frames:createErrorMsgFrame(frameTitle)

function msgFrame:getMsgFrame()
	return msgFrame
end
function msgFrame:showFrame()
	frames:showFrame( msgFrame )
end
function msgFrame:eraseText()  
	frames:clearFrame( msgFrame )
end
function msgFrame:hideFrame()
	frames:hideFrame( msgFrame )
end
function msgFrame:hideMeter()
	frames:hideMeter( msgFrame )
end
function msgFrame:showMeter()
    if errorMsgFrame == nil then 
        return
	end
	if errorMsgFrame:IsVisible() == false then
		errorMsgFrame:Show()
	end
end
function msgFrame:postMsg( msg )
	frames:showFrame( msgFrame )
	frames.Text:Insert( msg )
end
function msgFrame:postErrorMsg( msg )
	frames:showFrame( errorMsgFrame )
	errorMsgFrame.Text:Insert( msg )
end
function msgFrame:postResult( result )

	if result[1] ~= FAILURE then return end
	
	local resultString = string.format("[FAILURE] %s\n%s", result[2], result[3] )
	errorMsgFrame.Text:Insert( resultString )
	errorMsgFrame:Show()
end
function msgFrame:clearText()
	frames:clearFrameText()
end

