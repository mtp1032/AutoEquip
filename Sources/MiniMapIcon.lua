--------------------------------------------------------------------------------------
-- MiniMapIcon.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.MiniMapIcon = {}
local addonIcon = AutoEquip.MiniMapIcon -- unused for now

local auto = AutoEquip.AutoEquip
local L = AutoEquip.Locales
local dbg = AutoEquip.Debug
local menu = AutoEquip.OptionsMenu  -- Ensure menu is properly referenced
local msgFrame = AutoEquip.MsgFrame

-- Interface/ICONS/INV_Fishingpole_05.blp, 251534
-- Interface/ICONS/INV_Fishingpole_03.blp, 132933
-- Interface/ICONS/INV_Misc_Bag_16.blp, 133649

-- local ICON_AUTO_EQUIP = 251534  -- Fishing Pole
-- local ICON_AUTO_EQUIP = 132933  -- Fishing Pole
local ICON_AUTO_EQUIP = "Interface/ICONS/INV_Fishingpole_05.blp"  -- or whichever icon you prefer

-- register the addon with ACE
local addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0")

-- Create the click handler for the minimap icon
local function OnMinimapClick(self, button)
    if button == "LeftButton" and not IsShiftKeyDown() then
        local anyAvailable, reason = auto:setsAreAvailable()
        if not anyAvailable then 
            msgFrame:postErrorMsg(reason)
            -- menu:hide()
        else
            menu:show()
        end
    elseif button == "RightButton" then
        -- Handle right-click if needed
    end
end

-- The addon's icon state (e.g., position, etc.,) is kept in the AutoEquipDB. Therefore
-- this is set as the ##SavedVariable in the .toc file
local AutoEquip_DB = LibStub("LibDataBroker-1.1"):NewDataObject( ADDON_NAME, 
{
    type = "data source",
    text = ADDON_NAME,
    icon = ICON_AUTO_EQUIP,  -- Set the icon here
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(L["ADDON_AND_VERSION"])
        tooltip:AddLine(L["LEFTCLICK_FOR_OPTIONS_MENU"])
    end, 
    OnClick = OnMinimapClick  -- Assign the click handler
})

-- Create the actual icon
local icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AutoEquip_DB", 
        { profile = { minimap = { hide = false, }, }, }) 
    icon:Register(ADDON_NAME, AutoEquip_DB, self.db.profile.minimap)
end
