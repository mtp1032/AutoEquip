## NAME: AutoEquip
##### GITHUB: https://github.com/mtp1032/AutoEquip
### PURPOSE:
Eliminate the need to manually equip a rest XP set (e.g., an armor set containing one or more heirloom items) when entering a rest area. When leaving the rest area, AutoEquip will restore the armor set the character was previously wearing when s/he entered the resting area.
## USE CASE:
Suppose a character has two armor sets, one for questing called "DPS", and another for accumulating rest XP (or other resting benefits) called "RESTXP". With AutoEquip configured, when the character enters a rest area (e.g., GoldShire), the addon automatically equips the RESTXP set. When the player leaves the inn, the DPS set is automatically [re]equipped.
### CONFIGURATION
When configuring AutoEquip for the first time:
1. Before beginning, make sure your character is equipped with the set s/he will be using when not in a rest area.
2. Click the AutoEquip minimap icon, [X], to display the AutoEquip Options Menu.
3. Click the icon of the armor set to be equipped when entering a rest area (e.g., your restXP set)
>NOTE: Heirloom sets will often be your most potent DPS or Healing set (especially at lower levels). Therefore, in some situations your "resting" set and your saved-set will be identical.

### KNOWN BUGS
None yet. Of these I am blissfully ignorant.

### SUPPORTED EXPANSIONS
All expansions from Wrath and beyond are supported. Expansions previous to Wrath did not have Heirlooms.

### LOCALIZATION
Translations exist for Klingon, French, German, Italian, Korean, Russian, Spanish, Traditional and Simplified Chinese, and Norwegian. See AutoEquip\Locales\Locales.lua

### FUTURE UPDATES
1. The next minor release will offer an option to turn-off the notifications when your character enters or leaves a rest area.
2. The next major  release will support automatically equipping a riding set. When s/he dismounts, the set the character was previously wearing will be reequipped.




