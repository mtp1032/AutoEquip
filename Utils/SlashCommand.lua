--------------------------------------------------------------------------------------
-- SlashCommand.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 28 August, 2024
--------------------------------------------------------------------------------------

local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.SlashCommand = {}

local slash = AutoEquip.SlashCommand
local auto  = AutoEquip.AutoEquip
local dbg   = AutoEquip.Debug   -- use for error reporting services
local mf    = AutoEquip.MsgFrame

local L = AutoEquip.Locales

---------------- CODE STARTS HERE --------------------
-- Function to handle the slash commands
local function handleSlashCommand(cmd)
    local args = { strsplit(" ", cmd) }
    local option = args[1] and args[1]:lower()
    local arg  = args[2] and args[2]:lower()

    if option == "debug" then

        if arg == "enable" then
            dbg:enable()
            return
        elseif arg == "disable" then
            dbg:disable()
            return
        else
            mf:postHelpMsg("[AutoEquip] Usage - /auto debug enable|disable")
            return
        end
    elseif option == "help" then
        mf:helpFrame()
        return
    else
        mf:helpFrame()
        return
    end

    mf:postHelpMsg( string.format("Unknown option or option\n"))
end

-- Register the slash command
SLASH_AUTOEQUIP1 = "/auto"
SlashCmdList["AUTOEQUIP"] = handleSlashCommand

local fileName = "SlashCpmmand.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("%s loaded.", fileName ), 1,1,1 )
end
