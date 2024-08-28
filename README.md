## NAME: AutoEquip
##### GITHUB: https://github.com/mtp1032/AutoEquip
### PURPOSE:
Eliminate the need to manually equip a rest XP set (e.g., an armor set containing one or more heirloom items) when entering a rest area. When leaving the rest area, AutoEquip will restore the armor set the character was previously wearing when s/he entered the resting area.
## USE CASE:
Suppose a character has two armor sets, one for questing called "DPS", and another for accumulating rest XP (or other resting benefits) called "RESTXP". With AutoEquip configured, when the character enters the Goldshire Inn (a rest area) the addon equips the RESTXP set and saves the DPS set. When the player leaves the inn, the DPS set is [re]equipped.
### CONFIGURATION
When configuring AutoEquip for the first time:
1. From the Character menu, equip an armor set other than your rest XP set, e.g., your normal questing set.
2. Click the AutoEquip minimap icon ["XP"] to display AutoEquip's Options Menu.
3. Click the icon of the armor set to be equipped when entering a rest area (your restXP set)

NOTE 1: Heirloom sets will often be your most potent DPS or Healing set (especially at lower levels). Therefore, in some situations the "resting" set and the saved-set will be identical.

NOTE 2: If an armor set is incomplete, e.g., missing one or more items, instead of displaying the armor set icon, AutoEquip will display a red question mark icon alerting the player to update that armor set.

### SUPPORTED EXPANSIONS
Only The War Within, Shadowlands, Cataclysm, and Wrath expansions are supported. Classic Vanilla did not have Heirlooms.

### LOCALIZATION
Translations exist for French, German, Italian, Korean, Russian, Spanish, Traditional and Simplified Chinese, and Swedish. See AutoEquip\Locales\Locales.lua
