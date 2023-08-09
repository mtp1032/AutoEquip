--------------------------------------------------------------------------------------
-- MsgFrame.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local _, AutoEquip = ... 
AutoEquip.MsgFrame = {}
msgf = AutoEquip.MsgFrame
local sprintf = _G.string.format 
local L = AutoEquip.L
local dbg = equipdbg

local FAILURE = enus.FAILURE

local frameTitle = L["USER_MSG_FRAME"]
local msgFrame = frames:createMsgFrame( frameTitle)

local frameTitle = sprintf("ERROR: AutoEquip (V 1.0.0)" )
local errorMsgFrame = frames:createErrorMsgFrame(frameTitle)

function msgf:getMsgFrame()
	return msgFrame
end
function msgf:showFrame()
	frames:showFrame( msgFrame )
end
function msgf:eraseText()  
	frames:clearFrame( msgFrame )
end
function msgf:hideFrame()
	frames:hideFrame( msgFrame )
end
function msgf:hideMeter()
	frames:hideMeter( msgFrame )
end
function msgf:showMeter()
    if errorMsgFrame == nil then 
        return
	end
	if errorMsgFrame:IsVisible() == false then
		errorMsgFrame:Show()
	end
end
function msgf:postMsg( msg )
	frames:showFrame( msgFrame )
	msgFrame.Text:Insert( msg )
end
function msgf:postErrorMsg( msg )
	frames:showFrame( errorMsgFrame )
	errorMsgFrame.Text:Insert( msg )
end
function msgf:postResult( result )

	if result[1] ~= FAILURE then return end
	
	local resultString = sprintf("[FAILURE] %s\n%s", result[2], result[3] )
	errorMsgFrame.Text:Insert( resultString )
	errorMsgFrame:Show()
end
function msgf:clearText()
	fm:clearFrameText()
end

local fileName = "MsgFrame.lua"
if dbg:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end

