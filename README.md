# NAME: AutoEquip
# VERSION: 1.0.0
# GITHUB: https://github.com/mtp1032/AutoEquip
# TODO: Complete localization. At the moment, AutoEquip only supports English. See EnUS_AutoEquip.lua
# PURPOSE:
Eliminate the need to manually equip a rest XP set (e.g., an armor set containing one or more heirloom items) when entering a rest area. When leaving the rest area, AutoEquip will restore the armor set the character was previously wearing.
# USE CASE:
Suppose a character has two armor sets, one for questing called "DPS," and another for accumulating "RESTXP" or other resting benefits. So, when the character enters the Goldshire Inn (a rest area), the addon equips the RESTXP set and saves the DPS set. When the player leaves the inn, the DPS set is [re]equipped.
# CONFIGURATION
When configuring AutoEquip for the first time:
1. Click the AutoEquip minimap icon ("XP") to display AutoEquip's Options Menu.
2. Click the icon of the armor set to be equipped when entering a rest area.

NOTE 1: Heirloom sets will often be your most potent DPS or Healing set (especially at lower levels). Therefore, in some situations the "resting" set and the "DPS" set will be identical.

NOTE 2: If an armor set is incomplete, e.g., missing one or more items, instead of displaying the armor set icon, AutoEquip will display a red question mark icon alerting the player to update that armor set.

# SUPPORTED EXPANSIONS
Only Retail and Wrath expansions are supported. Classic Vanilla does not have Heirlooms.