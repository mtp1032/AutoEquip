-----------------------------------------------------------------
-- File: DebugTools.lua
-----------------------------------------------------------------

local _, AutoEquip = ...

local fileName = "DebugTools.lua"

if not AutoEquip.Core or not AutoEquip.Core.loaded then
    print("Core.lua failed to load")
    return
end

local core = AutoEquip.Core

local dbg = {}
AutoEquip.DebugTools = dbg

local messages = {}
local messageHandler

local function getMessagePrefix(stackTrace)
    stackTrace = stackTrace or debugstack(3)

    local sourceFile, lineNumber =
        stackTrace:match("[\\/]([^\\/:]+):(%d+)")

    if not sourceFile or not lineNumber then
        return "[Unknown:0] "
    end

    return string.format(
        "[%s:%s] ",
        sourceFile,
        lineNumber
    )
end

local function formatMessage(...)
    local values = {}
    local valueCount = select("#", ...)

    for index = 1, valueCount do
        local value = select(index, ...)

        if value == nil then
            value = "<nil>"
        elseif type(value) ~= "string" then
            value = tostring(value)
        end

        values[#values + 1] = value
    end

    return table.concat(values, " ")
end

function dbg:print(...)
    if not core:isDebuggingEnabled() then
        return
    end

    local message =
        getMessagePrefix(debugstack(2))
        .. formatMessage(...)

    messages[#messages + 1] = message

    if messageHandler then
        messageHandler(message)
    end
end

function dbg:enable()
    core:enableDebugging()
end

function dbg:disable()
    core:disableDebugging()
end

function dbg:isEnabled()
    return core:isDebuggingEnabled()
end

function dbg:getMessages()
    local messageCopy = {}

    for index, message in ipairs(messages) do
        messageCopy[index] = message
    end

    return messageCopy
end

function dbg:getText()
    return table.concat(messages, "\n")
end

function dbg:clear()
    wipe(messages)
end

function dbg:setMessageHandler(handler)
    if handler ~= nil and type(handler) ~= "function" then
        error("Debug message handler must be a function or nil.")
    end

    messageHandler = handler
end

dbg.loaded = true

if core:isDebuggingEnabled() then
    print(fileName .. " loaded")
end