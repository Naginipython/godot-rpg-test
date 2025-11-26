# godot-rpg-test
Inspired by Undertale, Deltarune, Omori, and Chrono Gear: The Warden of Time, the idea is to see if I can create the major gameplay elements of a game where I'd use the VTuber characters from Phase Connect and make a turn-based jRPG, with overworld akin to Pokemon & Pokemon Myserty Dungeon overworld gameplay, but turn-based combat would be similar to Undertale & Deltarune's, where boss attacks are a rhythm mini game.\
I also plan to add more things to test out, seen below
Please note, all of the assets used are entirely temporary. Overworld sprites will eventually be more similar to the combat menu's images, but for now I am using a free soldier man, and an orc to easily identify enemies. Overworld portrait are will of course change, they are currently an emotion+dialogue test. Combat menu pictures will eventually be more similar to the overworld portraits.

## To run:
Open Godot, click "import" and click this project's `project.godot`.

Afterwards, open project and run in the editor with f5 or pressing the play button in the top right

## Controls:
wasd are used for world movement. Hold shift to move faster

Inside the turn-based combat, wasd for selection, 'e' and spacebar are used for clicking selection, 'q' and escape are used for going back, and 'r' is a debug key to exit the combat (currently no other way to exit).\
In Rhythm game, asd are used to press the keys

## Current features:
In world:

- Tile-based movement, with collisions (Castle doesn't have colliders on purpose)
- Running & walking
- Enemy spawning/respawning after killed. Respawning happens off-screen, after a timer (Seems slightly broken)
- Enemy transition to combat
- Npc talking
- Player must face the NPC to talk to them (art will NOT show this, but when you click a direction it is recorded)
- Special NPCs that change TextUI's Portrait, border, emotional highlight and title
- Story changes that change NPC text (Enter enemy combat, press 'r', talk to yellow NPC)
- Environmental damage that pushes back
- NPCs have a dialogue manager, with temporary dialogue upon flag triggers, default dialogue, and dialogue for if story progresses
	- Yellow NPC has flag trigger dialogue and orange one has story progress dialogue (both viewable when beat enemy (press r))

In combat:

- Cute player menu animation
- Attack button selection (Others are WIP)
- Attack selection
- Attack box expansion & closing
- Turn-based moves (1 > 2 > 3 > 4 > boss > 1> ...)
- Attacks damage boss (WIP: Text to say it does)
- Boss attacks in a rhythm game
- Boss attacks damage players
- Rhythm game press zones defined (May be tweaked)
- Cute player damage animation
- Cute boss attack start/end animation
- Beating enemy (pressing r) triggers dialogue flag for Boss_Defeated
- Beating enemy (pressing r) progresses story tracker

## Issues
There is a slight chance the data in `assets/char_data/` get their array of strings called `attacks` deleted. If you double-click the `.tres` files, in the right menu, you can click Combat dropdown > click 'PackedStringArray' next to 'attacks', then add element of a random name where `<null>` is

## Planned features
combat:
- Attack textbox/boss shit talk
- Full attack list
- Attack details
- Actions
- Actions buff strategy pattern
- Collab bar (built on attack_game)
- Collabs (what does this do?)
- Items
- attack_game uses tiles instead of timer
- attack_game differing patterns (2 hits, sliding, holding)
- multiple enemies
- Dead characters can't attack or be attacked (even mid attack_game)

world:
- interactables
- player follow
- retain HP & stats
- damaging tiles
- pushables

Art (paid):
- World Sprites
	- Walking (4 directions)
	- Simple attack?
- Enemy Full body sprites
- Portraits (like: https://sprites.pmdcollab.org/)
	- Normal
	- Happy
	- Joyous
	- Angry
	- Sad
	- Teary?
	- Crying
	- Determined
	- Dizzy
	- Surprised
- Cool big panning screens (pixelart)
- World tilesheets
	- Great Library
	- Jelly's Kingdom
	- Euphoria Empire
	- Lawless Lands
	- Goldfish Kingdom

Story:
- 
