extends CombatState

var player_menus: Array[PlayerMenu]
var player_used: int
var idx: int = 0

func enter(_prev: String) -> void:
	player_menus = combat.player_menus
	player_used = combat.turn
	idx = 0 if player_used != 0 else 1
	player_menus[idx].selected = true
	player_menus[player_used].selected = false
	
	if not combat.choose_char_act.can_target_self:
		player_menus[player_used].disable()

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left"):
		player_menus[idx].selected = false
		idx -= 1
		if idx < 0: 
			idx = 3
		if idx == player_used and not combat.choose_char_act.can_target_self:
			idx -= 1
			if idx < 0: 
				idx = 3
		player_menus[idx].selected = true
	if event.is_action_pressed("right"):
		player_menus[idx].selected = false
		idx += 1
		if idx > 3:
			idx = 0
		if idx == player_used and not combat.choose_char_act.can_target_self:
			idx += 1
			if idx > 3:
				idx = 0
		player_menus[idx].selected = true
	
	if event.is_action_pressed("select"):
		get_viewport().set_input_as_handled() # To prevent Player_Menu Main > Actions
		use_action(idx)

func use_action(selected_idx: int) -> void:
	if combat.choose_char_act.type == Action.ActionType.Heal:
		var ch: CharacterData = GameManager.get_char_data(player_menus[selected_idx].char_id)
		ch.health += combat.choose_char_act.amount
		change_state.emit(self, "main")

func exit(_next: String) -> void:
	player_menus[player_used].enable()
	player_menus[idx].selected = false
	combat.choose_char_act = null
	combat.next_turn()
