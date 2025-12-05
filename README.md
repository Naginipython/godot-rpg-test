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
menus:

- Main Menu creates new save

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
- Going to the left will trigger a cutscene, which will only trigger with prior story. Small position check added too

In combat:

- Cute player menu animation
- Attack/Action/Item button selection
- Attack/Action/Item selection
- Attack/Action/Item box expansion & closing
- Actions implementation completed: Healing
- Action can choose player (where applicable)
- Turn-based moves (1 > 2 > 3 > 4 > boss > 1> ...)
- Turns can go canceled & go backwards (4 > 3 > 2 > 1)
- Attacks damage boss
- Boss attacks in a rhythm game
- Boss attacks damage players
- Rhythm game press zones defined (May be tweaked)
- Cute player damage animation
- Cute boss attack start/end animation
- Beating enemy triggers dialogue flag for Boss_Defeated
- Text UI now works in combat
- Dead characters cannot attack

## Planned features
menus:

- Loads data
- change party

combat:

- Attack implementation: w/ buff
- Attack details
- Actions implementation: buffs and debuffs
- Items implementation & decrement
- Item chooses character
- Collab bar (built on attack_game)
- Collabs (what does this do?)
- attack_game uses tiles instead of timer
- attack_game differing patterns (2 hits, sliding, holding)
- multiple enemies w/combined attacks (that coordinate)
- Full attack list
- Full action list
- Item list
- Boss special interactions

world:

- interactables
	- Sign
	- Choices NPC? (Clio to game?)
- player follow
- retain HP, stats, and items
- damaging tiles (1/2 working)
- pushables
- save (correctly, when full dataset is settled)

Art (paid):
- World Sprites
	- Walking (4 directions)
	- Simple attack?
- Enemy Full body sprites
- Player attack/action animation sprites
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
- lmao
