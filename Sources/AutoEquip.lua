--------------------------------------------------------------------------------------
-- AutoEquip.lua
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 26 April, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ...

------------------------------------------------------------
--                  NAMESPACE LAYOUT
------------------------------------------------------------
AutoEquip = AutoEquip or {}
AutoEquip.AutoEquip = {}
local auto = AutoEquip.AutoEquip

local L = AutoEquip.Locales
local dbg       = AutoEquip.Debug	-- use for error reporting services
local mf        = AutoEquip.MsgFrame
local frames    = AutoEquip.Frames

local optionsPanel = nil
local armorSetsDB = {}

local EMPTY_STR = ""
local SUCCESS   = true

local RED = 1
local GREEN = 2
local FADE_OUT_DURATION  = 10 -- seconds for the notification message to fade out.

local function setRestingSetId( restingSetId )
    assert( restingSetId ~= nil )
    autoEquip_Resting_SetId = restingSetId
end
local function setPreviousSetId( savedSetId )
    assert( savedSetId ~= nil )
    autoEquip_Previous_SetId  = savedSetId
end

-- Initialize the saved variables
-- This function is called by the ADDON_LOADED event
local function initializeSavedVariables()
    if autoEquip_Resting_SetId == nil then
       autoEquip_Resting_SetId = nil
    end

    if autoEquip_Previous_SetId == nil then
       autoEquip_Previous_SetId = nil         
    end

    if autoEquip_Saved_Debug == nil then
        autoEquip_Saved_Debug = nil
    end
end

initializeSavedVariables()

-- local setName = getSetNameByID( setId )
local function getSetNameById( setId )
    local setName = nil
    for i = 1, #armorSetsDB do
        if armorSetsDB[i].setId == setId then
            setName = armorSetsDB[i].setName
        end
    end
    return setName
end

local function getEquipmentSetRecords()
    local recordRestingSet = nil
    local recordPreviousSet = nil

    for i = 1, #armorSetsDB do
        local record = armorSetsDB[i]
        if record.setId == autoEquip_Resting_SetId then
            recordRestingSet = record
            break;
        end
    end
    assert( recordRestingSet ~= nil )

    for i = 1, #armorSetsDB do
        local record = armorSetsDB[i]
        if record.setId == autoEquip_Previous_SetId then
            recordPreviousSet = record
            break;
        end
    end
    assert( recordPreviousSet ~= nil )

    return recordRestingSet, recordPreviousSet
end
local function itemsAreMissing( setId )
    local numMissingItems = 0

    for i = 1, #armorSetsDB do
        local record = armorSetsDB[i]
        if record.setId == setId then
            if record.numMissingItems > 0 then
                numMissingItems = record.numMissingItems
                break
            end
        end
    end
    return numMissingItems 
end
local function initializeArmorSetsDB(callback)
    armorSetsDB = {}  -- Clear any existing data
    
    local function populateArmorSets(setIds)
        for i = 1, #setIds do
            local setName, iconFileID, setId, equipped, _, _, _, numItemsLost = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
            armorSetsDB[i] = {
                setId           = setId,
                setName         = setName,
                iconId          = iconFileID,
                isEquipped      = equipped,
                numMissingItems = numItemsLost
            }
        end
        -- -- dbg:print("Armor sets database populated with " .. #armorSetsDB .. " sets.")
        if callback then callback(armorSetsDB) end
        return #armorSetsDB
    end

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()

    local numArmorSets = 0
    if #setIds == 0 then
        C_Timer.After(0.5, function()
            setIds = C_EquipmentSet.GetEquipmentSetIDs()
            if #setIds > 0 then
                numArmorSets = populateArmorSets(setIds)
            else
                -- -- dbg:print("No armor sets found after retry.")
            end
        end)
    else
        numArmorSets = populateArmorSets(setIds)
    end
    return numArmorSets
end

-- =========================================================================
---                         services
-- =========================================================================
local function equipSet( setId, setName )
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    
    if itemsAreMissing( setId ) > 0 then
        local reason = string.format("%s could not be equipped - Set is missing one or more items", setName)
        result = dbg:setResult( reason, dbg:prefix() )
        return result
    end   

    local successful = C_EquipmentSet.UseEquipmentSet( setId )
    if not successful then
        local reason = string.format("%s %s could not be equipped", "SYSTEM: ", setName )
        result = dbg:setResult( reason, dbg:prefix() )
        return result
    end
    return result
end
function auto:getEquippedSetName()
    local setIds = initializeArmorSetsDB()
    assert( setIds > 0 )

    local setName = nil
    for i = 1, #armorSetsDB do
        local record = armorSetsDB[i]
        if record.isEquipped then
            setName = record.setName
            break;
        end
    end
    return setName
end

-- called when player clicks on one of the player's equipment set icons.
function auto:setRestXpSet( inputXPsetName ) -- Set only via the options menu
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

    assert( inputXPsetName ~= nil )
    local recs = initializeArmorSetsDB()
    assert( recs > 0 )

    -- dbg:print()
    local recordRestingSet = nil
    local equippedSetRecord = nil

    for i = 1, #armorSetsDB do
        local record = armorSetsDB[i]
        if record.setName == inputXPsetName then
            recordRestingSet = record
            -- -- dbg:print( recordRestingSet.setName )
        end
        if record.isEquipped then
            equippedSetRecord = record
            -- -- dbg:print( equippedSetRecord.setName )
        end
    end

    -- dbg:print()
    if IsResting() then 
        result = equipSet( recordRestingSet.setId, recordRestingSet.setName )
        if not result[1] then
            return result
        end
        -- dbg:print("Equipped ", recordRestingSet.setName )
    end
    setRestingSetId( recordRestingSet.setId)
    setPreviousSetId( equippedSetRecord.setId )

    -- dbg:print()
    return result
end

function auto:getAllArmorSetIds()
    local recs = initializeArmorSetsDB()
    -- -- dbg:print( recs )

    local setIds = {}
    for i = 1, #armorSetsDB do
        local record = armorSetsDB[i]
        setIds[i] = record.setId
        -- -- dbg:print( "setId", setIds[i])
    end
    -- -- dbg:print( #setIds )
    return setIds
end

--------------------- NOTIFICATIONS ---------------------
-- Hook into the UIErrorsFrame to catch the EQUIPMENT_MANAGER_MISSING_ITEM event
local function customErrorMessage( message)
       UIErrorsFrame:AddMessage(message, 1.0, 1.0, 1.0, 53, 5)
end

-- Create a frame for displaying entering and leaving rest areas.
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
local function notifyEquipmentChange( message, duration, color )
    notificationText:SetText(message)
    if color == RED then
        notificationText:SetTextColor(1.0, 0.0, 0.0)  -- Red color for the text
        notificationText:SetShadowOffset(1, -1)  -- Black shadow to match Blizzard's combat text
    end
    if color == GREEN then
        notificationText:SetTextColor(0.0, 1.0, 0.0)  -- Green color for the text
        notificationText:SetShadowOffset(1, -1)  -- Black shadow to match Blizzard's combat text
    end
    notificationFrame:Show()
    -- Set up a fade-out effect
    -- duration, example, 5 seconds
    -- Ending Alpha. 0 is the visibility.
    UIFrameFadeOut( notificationFrame, duration, 1, 0)
    
end
---------------------------------------------------------

local function onAddonLoaded()
    if autoEquip_Saved_Debug == nil then    -- set to the default value, false
        dbg:disable()
        return
    end
    if autoEquip_Saved_Debug == true then
        dbg:enable()
        return
    end
    if autoEquip_Saved_Debug == false then
        dbg:disable()
        return
    end
end

-- Store the original error handler so we can fall back on it
local originalErrorFrame = UIErrorsFrame:GetScript("OnEvent")

-- Set a custom error message handler for UIErrorsFrame
-- https://warcraft.wiki.gg/wiki/API_GetGameMessageInfo
-- stringId, soundKitID, voiceID = GetGameMessageInfo(messageType)
-- stringId is a global string such as ERR_EQUIPMENT_MANAGER_MISSING_ITEM_S
UIErrorsFrame:SetScript("OnEvent", function(self, event, errNum, errMsg, ...)
    if event == "UI_ERROR_MESSAGE" then


        -- Fetch the string associated with the error number (errNum)
        local message = GetGameMessageInfo(errNum)
        
        -- Check if the error number matches specific errors
        if errNum == 1038 or errNum == 1002 then
            -- errNum == 1038
            -- message == ERR_EQUIPMENT_MANAGER_MISSING_ITEM_S
            errMsg = string.format("[SYSERR] %s", errMsg )
            mf:postMsg( errMsg )
            UIErrorsFrame:AddMessage(errMsg, 1.0, 0.0, 0.0)
        else
            -- Call the original event handler for other errors
            originalErrorFrame(self, event, errNum, errMsg, ...)
        end
    else
        -- Handle non-error events
        originalErrorFrame(self, event, errNum, errMsg, ...)
    end
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UI_ERROR_MESSAGE")

eventFrame:SetScript("OnEvent",
function(self, event, ...)
    local arg = {...}
    local result = { SUCCESS, EMPTY_STR, EMPTY_STR}
    if event == "PLAYER_LOGIN" then
        local numArmorSets = initializeArmorSetsDB()
    
        -- if AutoEquip has not been initialized, then return
        if autoEquip_Resting_SetId == nil and autoEquip_Previous_SetId == nil then
            return
        end


        local recordRestingSet, recordPreviousSet = getEquipmentSetRecords()

        if IsResting() then -- equip the resting set, if not already set
            if not recordRestingSet.isEquipped then
                result = equipSet( recordRestingSet.setId, recordRestingSet.setName )
                if not result[1] then 
                    mf:postResult( result ) 
                    return 
                end
                -- -- dbg:print("Equipped set", recordRestingSet.setName )
            end
        end

        local msg = string.format( L["LOGIN_MESSAGE"], ADDON_NAME, UnitName("Player"), recordRestingSet.setName, autoEquip_Resting_SetId )
        DEFAULT_CHAT_FRAME:AddMessage( msg, 0,1,0 )
    end
    -- Informational: event is fired when an equipment set has finished equipping.    
    if event == "EQUIPMENT_SWAP_FINISHED" then
        local result = {SUCCESS, EMPTY_STR, EMPTY_STR }
        local successful, setId = ...
        C_Timer.After(0.1, 
        function()
            if successful then 
                local setName = getSetNameById( setId )
                local msg = string.format(L["PLAYER_SWITCHED_SETS"], ADDON_NAME, UnitName("Player"), setName, setId ) 
                DEFAULT_CHAT_FRAME:AddMessage( msg, 0,1,0 )
            end
        end)
    end

    -- handling this event is what the addon is all about
    if event == "PLAYER_UPDATE_RESTING" then
        -- check that the player has initialized AutoEquip.
        if autoEquip_Resting_SetId == nil or autoEquip_Previous_SetId == nil then
            return
        end
        -- -- dbg:print( event )
        local recs = initializeArmorSetsDB()
        assert( recs > 0 )
    
        local msg = nil
        local color = nil
        local isEquipped = nil
        local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

        local recordRestingSet, recordPreviousSet = getEquipmentSetRecords()

        if IsResting() then
            color = GREEN
        
            -- Player has entered a resting area. If the player is not wearing
            -- the resting set, then equip it. If he is, do nothing.
            if recordRestingSet[isEquipped] then return end
            
            result = equipSet( recordRestingSet.setId, recordRestingSet.setName )
            if not result[1] then
                mf:postResult( result )
                return
            end
            msg = string.format( L["ENTERED_REST_AREA"], UnitName("Player"), recordRestingSet.setName )
        else
            color = RED
        
            result = equipSet( recordPreviousSet.setId, recordPreviousSet.setName )
            if not result[1] then
                mf:postResult( result )
                return
            end
            msg = string.format( L["LEFT_REST_AREA"], UnitName("Player"), recordPreviousSet.setName )
        end

        notifyEquipmentChange( msg, FADE_OUT_DURATION, color )
        if dbg:debuggingIsEnabled() then
            DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0)
        end
        return
    end

    if event == "ADDON_LOADED" and arg[1] == ADDON_NAME then

        onAddonLoaded()
        initializeSavedVariables()
        -- Unregister the event after initializing
        DEFAULT_CHAT_FRAME:AddMessage(L["ADDON_LOADED_MSG"], 0,1,0 )
        eventFrame:UnregisterEvent("ADDON_LOADED")
        return
    end
end)


local fileName = "AutoEquip.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("[%s] %s loaded.", ADDON_NAME,fileName ), 1,1,1 )
end

------ code and functions that are subject to deletion -------- return true/false if player is eligible to use equipment sets
