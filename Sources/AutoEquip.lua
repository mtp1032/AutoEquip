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

local EMPTY_STR = ""
local SUCCESS   = true

local RED = 1
local GREEN = 2
local FADE_OUT_DURATION  = 5 -- seconds for the notification message to fade out.

local function setRestingSetId( restingSetId )
    assert( restingSetId ~= nil )
    autoEquip_Resting_SetId = restingSetId

end
local function setSavedSetId( savedSetId )
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

-- =========================================================================
---                         services
-- =========================================================================
local function canUseEquipmentSets()
    local result = { SUCCESS, EMPTY_STR, EMPTY_STR}

    -- players with Ilevel < 10 cannot use the equipment manager
    if UnitLevel("Player") < 10 then
        local reason = string.format( L["LEVEL_REQUIREMENT"], UnitName("Player"))
        result = dbg:setResult( reason, dbg:prefix() )
        return false, result
    end

    -- return if the player has no defined equipment sets
    local numEquipSets = C_EquipmentSet.GetNumEquipmentSets()
    if numEquipSets == 0 then
        local reason = string.format( L["NO_EQUIPMENT_SETS_DEFINED"], UnitName("Player"))
        result = dbg:setResult( reason, dbg:prefix() )
        return false, result
    end

        -- check whether the player's equipment sets are usuable. @@ dont't know what this means
        if not C_EquipmentSet.CanUseEquipmentSets() then
            local reason = string.format( L["CANNOT_USE_EQUIPMENT_SETS"], UnitName("Player"))
            result = dbg:setResult( reason, dbg:prefix() )
            return false, result
        end    

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    if setIds == nil then
        local reason = string.format( L["NO_EQUIPMENT_SETS_DEFINED"], UnitName("Player"))
        result = dbg:setResult( reason, dbg:prefix() )
        return false, result
    end
    return true, result
end
-- returns a table of equipment set names
local function enumSetNames()
    local setNames = {}

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        setNames[i] = C_EquipmentSet.GetEquipmentSetInfo( setIds[i] )        
    end
    return setNames
end
-- returns the setName, isEquipped, and result.
local function getSetNameByID( setId )
    assert( setId ~= nil )
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local setName = nil
    local isEquipped = false

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        local setName, _, id, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if setId == id then 
            isEquipped = equipped
            return setName, isEquipped, result
        end
    end

    -- We're here because the input setId did not identify any of the player's armor sets.
    local param = string.format("Id %d", setId )
    local reason = string.format(L["SET_DOES_NOT_EXIST"], param  )
    result = dbg:setResult( reason, dbg:prefix() )
    return nil, nil, result
end
-- returns the setId, isEquipped, and result
local function getSetIdByName(setName)
    assert( setName ~= nil )
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local isEquipped = nil
    local setId = nil

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        local name, _, id, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if name == setName then 
            isEquipped = equipped
            setId = id
            return setId, isEquipped, result
        end
    end
    -- we're here because the player's input armor set name was not found.
    assert( setId == nil )

    local param = string.format("Id %d", setId )
    local reason = string.format(L["SET_DOES_NOT_EXIST"], param  )
    result = dbg:setResult( reason, dbg:prefix() )

    return nil, nil, result
end
-- returns isEquipped, result (result is always SUCCESSFUL)
local function isSetEquipped(setId)
    assert( setId ~= nil )

    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local exists = false
    local isEquipped = false

    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, #setIds do
        local _, _, id, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if setId == id then
            isEquipped = equipped
            exists = true
            return isEquipped, result
        end
    end
    if not exists then
        local str = string.format(L["SET_DOES_NOT_EXIST"])
        result = dbg:setResult( str, dbg:prefix() )
    end
    return isEquipped, result
end
-- return setId, setName, result. Returns nil if no set is equipped.
local function getEquippedSet()
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
    local numSets = 0

    local available, result = canUseEquipmentSets()
    if not available then
        return nil, nil, result
    end

    -- are any sets defined/available
    numSets = C_EquipmentSet.GetNumEquipmentSets()
    if numSets == 0 then
        local msg = string.format(L["NO_SETS_DEFINED"], UnitName("Player"), numSets )
        result = dbg:setResult( msg, dbg:prefix() )
        return nil, nil, result            
    end
    
    local setIds = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, numSets do
        local setName, _, setId, equipped = C_EquipmentSet.GetEquipmentSetInfo(setIds[i])
        if equipped then 
            return setId, setName, result
        end
    end
    local msg = string.format(L["PLAYER_NOT_EQUIPPED"], UnitName("Player"))
    result = dbg:setResult( msg, dbg:prefix())
    return nil, nil, result
end
function auto:setsAreAvailable()
    return canUseEquipmentSets()
end
function auto:enumSets()
    local sets = enumSetNames()
    for i = 1, #sets do
        mf:postMsg(string.format("%s\n", sets[1]))
    end
end
function auto:getEquippedSet()
    return getEquippedSet()
end
-- called by Options panel. Function is hear because TOC loads this
-- before OptionsPanel is loaded. In effect, this is like a callback.
function auto:setOptionsPanel( panel )
    optionsPanel = panel
    optionsPanel:Hide()
end
-- called with player clicks on one of the player's equipment set icons.
function auto:setRestXpSet( inputXPsetName ) -- Set only via the options menu
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

    assert( inputXPsetName ~= nil )
    local canUse, result = canUseEquipmentSets()
    if not canUse then 
        -- optionsPanel:Hide()
        return result 
    end

    -- Get the id of the set indicated by inputXPsetName
    local restingSetId, equipped, result = getSetIdByName( inputXPsetName )
    if not result[1] then 
        -- optionsPanel:Hide()
        return result
    end

    -- Get the set with which the player is currently equipped. 
    local equippedSetId, _, result = getEquippedSet()
    if not result[1] then
        -- optionsPanel:Hide()
        return result
    end

    setRestingSetId( restingSetId ) -- < Input by the client
    setSavedSetId( equippedSetId )  -- < The client's current armor set

    -- If player is already in a resting zone and his resting set is not equipped,
    -- then equip the resting set.
    if IsResting() then 
        local isEquipped, result = isSetEquipped( restingSetId )
        if not result[1] then 
            -- optionsPanel:Hide()
            mf:postResult( result ) 
            return 
        end

        if not isEquipped then
            local successful = C_EquipmentSet.UseEquipmentSet( restingSetId )
            if not successful then
                local reason = string.format(L["FAILED_TO_EQUIP_SET"], inputXPsetName)
                local result = dbg:setResult( reason, dbg:prefix() )
                mf:postResult( result )
                -- optionsPanel:Hide()
                return result
            end
        end
    end
    -- optionsPanel:Hide()
    return result
end

--------------------- NOTIFICATIONS ---------------------
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
    
    C_Timer.After( duration, function()
        notificationFrame:Hide()
    end)
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

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")

eventFrame:SetScript("OnEvent",
function(self, event, ...)
    local arg = {...}

    if event == "PLAYER_LOGIN" then
        local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
        local numSets = C_EquipmentSet.GetNumEquipmentSets()
        local setId = nil
        local setName = nil

        local canUse, result = canUseEquipmentSets()
        if not canUse then return end

        setId, setName, result = getEquippedSet()
        if not result[1] then
            mf:postResult( result )
            return
        end

        local msg = string.format( L["LOGIN_MESSAGE"], ADDON_NAME, UnitName("Player"), setName, setId )
        DEFAULT_CHAT_FRAME:AddMessage( msg, 0,1,0 )
    end
    -- Informational: event is fired when an equipment set has finished equipping.    
    if event == "EQUIPMENT_SWAP_FINISHED" then
        local result = {SUCCESS, EMPTY_STR, EMPTY_STR }
        local successful, setId = ...
        C_Timer.After(0.1, 
        function()
            if successful then 
                local setName, isEquipped, result = getSetNameByID( setId )
                if not result[1] then 
                    mf:postResult( result ) 
                    return 
                end
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
        local msg = nil
        local color = nil
        local isEquipped = nil
        local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

        -- get the resting set Id and Name
        local restingSetName, _, result = getSetNameByID( autoEquip_Resting_SetId )
        if not result[1] then
            mf:postResult( result )
            return
        end
        local restingSetId, _, result = getSetIdByName( restingSetName )
        if not result[1] then
            mf:postResult( result )
            return
        end

        -- get the saved set Id and Name
        local savedSetName, _, result = getSetNameByID( autoEquip_Previous_SetId )
        if not result[1] then
            mf:postResult( result )
            return
        end
        local savedSetId, _, result = getSetIdByName( savedSetName )
        if not result[1] then
            mf:postResult( result )
            return
        end

        if IsResting() then
            color = GREEN
        
            -- Player has entered a resting area. If the player is not wearing
            -- the resting set, then equip it. If he is, do nothing.
            local isEquipped, result = isSetEquipped( restingSetId )
            if not result[1] then mf:postResult( result ) return end
            if isEquipped then return end

            local successful = C_EquipmentSet.UseEquipmentSet( restingSetId )
            if not successful then
                local reason = string.format(L["FAILED_TO_EQUIP_SET"], restingSetName )
                local result = dbg:setResult( reason, dbg:prefix() )
                mf:postResult( result )
                return
            end
            msg = string.format( L["ENTERED_REST_AREA"], UnitName("Player"), restingSetName)
        else
            color = RED
            -- Player has left the resting zone. Equip the saved set
            local successful = C_EquipmentSet.UseEquipmentSet( savedSetId )
            if not successful then
                local reason = string.format(L["FAILED_TO_EQUIP_SET"], savedSetName )
                local result = dbg:setResult( reason, dbg:prefix() )
                mf:postResult( result )
                return
            end
            msg = string.format( L["LEFT_REST_AREA"], UnitName("Player"), savedSetName )
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

-- Create a frame for displaying entering and leaving rest areas.


local fileName = "AutoEquip.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( string.format("[%s] %s loaded.", ADDON_NAME,fileName ), 1,1,1 )
end

------ code and functions that are subject to deletion -------- return true/false if player is eligible to use equipment sets
