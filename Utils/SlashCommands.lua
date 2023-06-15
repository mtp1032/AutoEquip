--------------------------------------------------------------------------------------
-- FILE NAME:       SlashCommands.lua 
-- AUTHOR:          Michael Peterson
-- ORIGINAL DATE:   27 April, 2023
local _, AutoEquip = ...
AutoEquip.SlashCommands = {}
slash = AutoEquip.SlashCommands

local L = AutoEquip.L
local sprintf = _G.string.format
local dbg = equipdbg

local s1 = sprintf("[HELP]\n") 
local s2 = sprintf("Syntax: /es [enum | equip] [,command parameters]\n")
local s3 = sprintf("  Enumerate all equipment sets:   /es enum\n")
local s4 = sprintf("  Equip the player's fishing set: /es equip fishing\n")
local errorString = s1 .. s2 .. s3 .. s4

-- pattern matching that skips leading whitespace and whitespace between cmd and args
-- any whitespace at end of args is retained
SLASH_AUTO_EQUIP_COMMANDS1 = "/setequip"
SLASH_AUTO_EQUIP_COMMANDS2 = "/set"
SLASH_AUTO_EQUIP_COMMANDS3 = "/es"
local function handler(msgStr, editbox)
    local isValid = false

    local cmd, options = msgStr:match("^(%S*)%s*(.-)$")

    -- valid commands are equip and enum
    cmd = string.upper( cmd )
    if cmd ~= "equip" and
        cmd ~= "enum" then
            isValid = false
            msgf:postMsg( errorString )
            return
    end
    if msgStr == nil and cmd ~= "enum" then
        msgf:postMsg( errorString )
        return
    end
    if msgStr == nil then
        msgf:postMsg( errorString )
        return
    end

    if cmd == "enum" and msgStr == nil then    -- passed test
        equip:enumSets()
        return
    end  
    
    -- elseif cmd == "equip" and options ~= "" then
    --     equip:set( options )
    --     return
    
    -- elseif cmd == "boe" and options ~= "help" then    -- passed test
    --     -- display some sort of help message
    --     msgf:postMsg( errorString)
    --     return
    
    -- else
    --     msgf:postMsg( sprintf( "[ERROR] %s - Unknown Command!\n", cmd ))
    --     return
    -- end
end
SlashCmdList["AUTO_EQUIP_COMMANDS"] = handler

-- ================== END PARSING ===============

local fileName = "SlashCommands.lua"
if dbg:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
