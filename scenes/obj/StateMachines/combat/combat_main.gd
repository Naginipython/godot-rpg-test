extends CombatState

func enter(prev: String) -> void:
	if prev == "attackgame":
		combat.player_menus[0].selected = true
		combat.turn = 0
	#if prev == "choice":
		#combat.player_menus[combat.turn].selected = true

func process(_delta: float) -> void:
	if combat.choose_char_act or combat.choose_char_itm:
		change_state.emit(self, "choice")
	if combat.turn == 4:
		change_state.emit(self, "applymoves")

func dialogue(convo: Conversation) -> void:
	for line in convo.lines:
		combat.lines.push_back(line)

func action(char_name: String, act: Action) -> void:
	# TODO Choice for enemy
	if act.type == Action.ActionType.AddDebuff || act.type == Action.ActionType.MultDebuff:
		pass
	else:
		if act.is_target_all:
			pass # heal or buff all
		else:
			combat.choose_char_act = act

func use_item(item: Item) -> void:
	combat.next_turn()
