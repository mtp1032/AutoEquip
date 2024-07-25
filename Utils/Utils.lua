--------------------------------------------------------------------------------------
-- Utils.lua
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 16 April, 2023 
--------------------------------------------------------------------------------------
local _, AutoEquip = ...
AutoEquip.Utils = {}
utils = AutoEquip.Utils

local L = AutoEquip.L
local dbg = equipdbg

function utils:displayMsg( msg )
	UIErrorsFrame:AddMessage( msg, 0.0, 1.0, 0.0 ) 
end

function utils:copyTable(t)
	local t2 = {}
	for k,v in pairs(t) do
	  t2[k] = v
	end
	return t2
  end
  
local fileName = "Utils.lua"
if dbg:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( string.format("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
