--------------------------------------------------------------------------------------
-- MiniMapIcon.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local _, AutoEquip = ...
AutoEquip.MiniMapIcon = {}
icon = AutoEquip.MiniMapIcon

local L = AutoEquip.L
local dbg = equipdbg
local menu = AutoEquip.OptionsMenu  -- Ensure menu is properly referenced

-- Interface/ICONS/INV_Fishingpole_05.blp, 251534
-- Interface/ICONS/INV_Fishingpole_03.blp, 132933
-- Interface/ICONS/INV_Misc_Bag_16.blp, 133649

-- local ICON_AUTO_EQUIP = 251534  -- Fishing Pole
-- local ICON_AUTO_EQUIP = 132933  -- Fishing Pole
local ICON_AUTO_EQUIP = 894556
local addonName = enus:getAddonName()

-- register the addon with ACE
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")

-- Create the click handler for the minimap icon
local function OnMinimapClick(self, button)
    if button == "LeftButton" and not IsShiftKeyDown() then
        local anyAvailable, reason = equip:setsAreAvailable()
        if not anyAvailable then 
            auto:postErrorMsg(reason)
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
local AutoEquip_DB = LibStub("LibDataBroker-1.1"):NewDataObject(enus.ADDON_NAME, 
{
    type = "data source",
    text = addonName,
    icon = ICON_AUTO_EQUIP,
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
    icon:Register(addonName, AutoEquip_DB, self.db.profile.minimap)
end

local fileName = "MiniMapIcon.lua"
if dbg:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage(string.format("%s loaded", fileName), 1.0, 1.0, 0.0)
end
