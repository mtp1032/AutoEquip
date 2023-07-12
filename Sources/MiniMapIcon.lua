--------------------------------------------------------------------------------------
-- AutoEquipIcon.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
local _, AutoEquip = ...
AutoEquip.AutoEquipIcon = {}
icon = AutoEquip.AutoEquipIcon

local L = AutoEquip.L
local dbg = equipdbg

local sprintf = _G.string.format

-- Interface/ICONS/INV_Fishingpole_05.blp, 251534
-- Interface/ICONS/INV_Fishingpole_03.blp, 132933
-- Interface/ICONS/INV_Misc_Bag_16.blp, 133649

-- local ICON_AUTO_EQUIP = 251534	-- Fishing Pole
-- local ICON_AUTO_EQUIP = 132933	-- Fishing Pole
local ICON_AUTO_EQUIP = 894556
local addonName = enus:getAddonName()

-- register the addon with ACE
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")

local shiftLeftClick 	= (button == "LeftButton") and IsShiftKeyDown()
local shiftRightClick 	= (button == "RightButton") and IsShiftKeyDown()
local altLeftClick 		= (button == "LeftButton") and IsAltKeyDown()
local altRightClick 	= (button == "RightButton") and IsAltKeyDown()
local rightButtonClick	= (button == "RightButton")

-- The addon's icon state (e.g., position, etc.,) is kept in the AutoEquipDB. Therefore
--  this is set as the ##SavedVariable in the .toc file
-- local AutoEquipDB = LibStub("LibDataBroker-1.1"):NewDataObject(boe.ADDON_NAME, 
local AutoEquip_DB = LibStub("LibDataBroker-1.1"):NewDataObject(enus.ADDON_NAME, 
	{
		type = "data source",
		text = addonName,
		icon = ICON_AUTO_EQUIP,
		OnTooltipShow = function( tooltip )
			tooltip:AddLine(L["ADDON_AND_VERSION"])
			tooltip:AddLine(L["LEFTCLICK_FOR_OPTIONS_MENU"] )
		end, 
		OnClick = function(self, button )
			-- LEFT CLICK - Display the options menu
			if button == "LeftButton" and not IsShiftKeyDown() then 
				menu:show()
			end
			-- -- RIGHT CLICK - Show the encounter reports
			-- if button == "RightButton" and not IsShiftKeyDown() then
			-- 	msgf:eraseText()
			-- 	cleu:summarizeEncounter()
			-- end
			-- if button == "LeftButton" and IsShiftKeyDown() then
			-- end
			-- if button == "RightButton" and IsShiftKeyDown() then
			-- 	msgf:eraseText()
			--end
	end,
	})

-- so far so good. Now, create the actual icon	
local icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AutoEquip_DB", 
					{ profile = { minimap = { hide = false, }, }, }) 
	icon:Register(addonName, AutoEquip_DB, self.db.profile.minimap) 
end

local fileName = "AutoEquipIcon.lua"
if dbg:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end

