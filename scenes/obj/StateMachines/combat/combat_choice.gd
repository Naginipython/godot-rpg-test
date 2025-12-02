extends CombatState

var player_menus: Array[PlayerMenu]
var player_used: int
var idx: int = 0
var all_hp_full = false

func enter(_prev: String) -> void:
	player_menus = combat.player_menus
	player_used = combat.turn
	player_menus[player_used].selected = false
	all_hp_full = false
	
	if combat.choose_char_act:
		if not combat.choose_char_act.can_target_self:
			player_menus[player_used].disable()
	
	# Disable ones that already are full
	if combat.choose_char_act:
		if combat.choose_char_act.type == Action.ActionType.Heal:
			hide_full_hp()
	if combat.choose_char_itm:
		if (
			combat.choose_char_itm.type == Item.ItemType.SingleHeal or
			combat.choose_char_act.type == Item.ItemType.MultHeal
			):
			hide_full_hp()
	
	# Select non-disabled
	for menu in player_menus:
		if not menu.is_disabled:
			menu.selected = true
			break

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left") and not all_hp_full:
		player_menus[idx].selected = false
		idx -= 1
		if idx < 0: 
			idx = 3
		while player_menus[idx].is_disabled:
			idx -= 1
			if idx < 0: 
				idx = 3
		player_menus[idx].selected = true
	if event.is_action_pressed("right") and not all_hp_full:
		player_menus[idx].selected = false
		idx += 1
		if idx > 3:
			idx = 0
		while player_menus[idx].is_disabled:
			idx += 1
			if idx > 3:
				idx = 0
		player_menus[idx].selected = true
	
	if event.is_action_pressed("select"):
		get_viewport().set_input_as_handled() # To prevent Player_Menu Main > Actions
		if combat.choose_char_act and not all_hp_full:
			use_action(idx)
		if combat.choose_char_itm and not all_hp_full:
			pass
	if event.is_action_pressed("return"):
		change_state.emit(self, "main")

func exit(_next: String) -> void:
	for pm in player_menus:
		pm.enable()
	player_menus[idx].selected = false
	combat.choose_char_act = null

func use_action(selected_idx: int) -> void:
	if combat.choose_char_act.type == Action.ActionType.Heal:
		combat.apply_target(player_menus[selected_idx].char_id)
		combat.next_turn()
		change_state.emit(self, "main")

func hide_full_hp() -> void:
	# Check if all are full
	if player_menus.all(func (p): return p.max_hp == p.hp):
		all_hp_full = true
	
	# Disable unable ones
	for pm in player_menus:
		if pm.max_hp == pm.hp:
			pm.disable()
