I've been thinking and have decided that we need to make two major changes before continuing with the Options menu.

FIRST CHANGE:  A MORE COMPREHENSIE DEBUG ENVIRONMENT
I would like to log every dbg:print() statement to a scrolling window frame. The only text written to the Chat window is a notice that the Addon has been loaded.

Here are the characteristics of the scrolling window frame:

a) scroll bar on right side. Scrolling is upwards. Just like the Chat frame. The most recent entry is at the bottom of the window.
b) Upper right corner is the Red X (Dismiss) button.
c) Title in the upper bar will be "AutoEquip Version xxx: Debug Info"
d) In the lower bar's right corner is a Clear button. When clicked the contents of the window are cleared, but not erased.
e) In the lower bar's left corner is an Exit button. When clicked, the contents of the window are deleted and window is cleared.
f) In the middle of the lower bar, is a Copy button. When clicked the contents of the window are copied into the player's buffer.

The window is for the developer. The user never need to see the window except when s/he encounter a bug. The user will then be advised to enable debugging. In this case, the player can copy and send the text to me, the developer.

This extended debug feature will be added to the "DebugTools.lua" file.

SECOND CHANGE: MOUNTING, RESTING, AND QUESTING SEMANTICS

There are only two location states: rest areas and non-rest areas. Therefore, 

When a player enters a rest area the resting set is equipped and no previous set is saved. Always.
When a player exits the rest area the questing set is equipped. Always. 
When a player mounts, the riding set is equipped.
When a player dismounts, if the player is in a rest area, the rest set is equipped. If not in a rest area the questing set is equipped.

simple. straightforward. 

This solves the problem of saving sets when, for example, a player wearing the questing and the riding set rides into a inn where he is automatically dismounted. First, the PLAYER_RESTING event is triggered, and the current riding set is saved and the resting set is equipped. Then when the DISMOUNT event occurs, resting set is saved and the riding set is reequipped.

The necessary changes will be principally in the AutoEquip.lua file. Also, the current Equipment State info will have to be changed ... but, if I'm right, much simplified.

We could solve issues like these (there are others) with some convoluted logic but it's simpler to equip the set appropriate to the location or role. Period.

