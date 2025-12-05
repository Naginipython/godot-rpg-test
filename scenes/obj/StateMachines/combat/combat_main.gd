extends CombatState

func enter(prev: String) -> void:
	if prev == "attackgame":
		combat.next_turn()
	if prev == "choice" and combat.turn < combat.player_menus.size():
			combat.player_menus[combat.turn].selected = true

func process(_delta: float) -> void:
	if combat.choose_char_act or combat.choose_char_itm:
		change_state.emit(self, "choice")
	if combat.turn == 4:
		change_state.emit(self, "applymoves")
