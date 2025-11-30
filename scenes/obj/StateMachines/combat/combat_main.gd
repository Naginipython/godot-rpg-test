extends CombatState

var menu_idx: int = 0
var turn: int = 0

func enter(_prev: String) -> void:
	combat.player_menus[0].selected = true
	turn = 0

func log_attack(line: String) -> void:
	combat.lines.push_back(DialogueLine.new(line))

func dialogue(convo: Conversation) -> void:
	for line in convo.lines:
		combat.lines.push_back(line)

func damage_boss(dmg: int) -> int:
	combat.boss_hp -= dmg
	next_turn()
	return combat.boss_hp

func action() -> void:
	next_turn()

func use_item(item: Item) -> void:
	next_turn()

func next_turn() -> void:
	combat.player_menus[menu_idx].selected = false
	turn += 1
	turn %= 5
	if turn != 4:
		combat.player_menus[menu_idx+1].prev_animation_playing = true
		menu_idx = turn
		combat.player_menus[menu_idx].selected = true
		# Ensures menu isn't automatically in actions
		await combat.player_menus[menu_idx-1].animation_player.animation_finished
		combat.player_menus[menu_idx].prev_animation_playing = false
	else:
		change_state.emit(self, "dialogue")
		#change_state.emit(self, "attackgame")
		menu_idx = 0
