--------------------------------------------------------------------------------------
-- Debug.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------

local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.Debug = {}	  
local dbg = AutoEquip.Debug	-- use for error reporting services

local EMPTY_STR 	= ""
local SUCCESS	= true
local FAILURE	= false

---------------------------------------------------------------------------------------------------
--                      PUBLIC/EXPORTED FUNCTIONS
----------------------------------------------------------------------------------------------------
-- Create a frame for displaying combat notifications
local notificationFrame = CreateFrame("Frame", "notificationFrame", UIParent)
notificationFrame:SetSize(300, 50)  -- Width, Height
notificationFrame:SetPoint("CENTER", 0, GetScreenHeight() * 0.375)  -- Positioning at X=0 and 3/4 from the bottom to the top
notificationFrame:Hide()  -- Initially hide the frame

-- Create the text inside the frame
local notificationText = notificationFrame:CreateFontString(nil, "OVERLAY")
notificationText:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")  -- Set the font, size, and outline
notificationText:SetPoint("CENTER", notificationFrame, "CENTER")  -- Center the text within the frame
notificationText:SetTextColor(0.0, 1.0, 0.0)  -- Red color for the text
notificationText:SetShadowOffset(1, -1)  -- Black shadow to match Blizzard's combat text

-- Function to display the notification
function dbg:notifyEquipmentChange(message, duration)
    notificationText:SetText(message)
    notificationFrame:Show()

    -- Set up a fade-out effect
    -- duration, example, 5 seconds
    -- Ending Alpha. 0 is the visibility.
    UIFrameFadeOut( notificationFrame, duration, 1, 0)
    
    -- Hide the frame after the fade is complete
    C_Timer.After( duration, function()
        notificationFrame:Hide()
    end)
end



function dbg:simpleStackTrace( stackTrace )
	if stackTrace == nil then stackTrace = debugstack(2) end

	local str = string.sub( stackTrace, 28 )
	local pieces = {strsplit( ":", str, 5 )}
	local len = strlen( pieces[1])
	dir = string.sub( pieces[1], 1, len - 2 )
	local simple = string.format("%s]%d", dir, pieces[2])
	return simple
end
function dbg:Prefix(stackTrace)
    stackTrace = stackTrace or debugstack(2)
    
    -- Extract the relevant part of the stack trace (filename and line number)
    local fileName, lineNumber = stackTrace:match("[\\/]([^\\/:]+):(%d+)")
    if not fileName or not lineNumber then
        return "[Unknown:0] "
    end

    -- Remove any trailing unwanted characters (e.g., `"]`, `*]`, `"`) from the filename
    fileName = fileName:gsub("[%]*\"]", "")

    -- Create the prefix with file name and line number, correctly formatted
    local prefix = string.format("[%s:%d] ", fileName, tonumber(lineNumber))
    return prefix
end
function dbg:Print(...)
    local prefix = dbg:Prefix(debugstack(2))

    -- Convert all arguments to strings and concatenate them with a space delimiter
    local args = {...}
    for i, v in ipairs(args) do
        args[i] = tostring(v)
    end

    local output = prefix .. table.concat(args, " ")

    -- Directly call the global print function
    print(output)
end
function dbg:setResult( reason, stackTrace )
	return 	{ FAILURE, reason, stackTrace }
end

