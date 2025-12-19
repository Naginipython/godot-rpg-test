extends PauseMenuState

var char_idx: int = 0

func enter(_prev: String) -> void:
	char_idx = 0
	select_char(char_idx)

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		get_viewport().set_input_as_handled()
		change_state.emit(self, "main")
	if get_tree().paused:
		if event.is_action_pressed("select"):
			#Open char
			pass
		if event.is_action_pressed("left"):
			char_idx -= 1
			if char_idx < 0: char_idx = 3
			select_char(char_idx)
		elif event.is_action_pressed("right"):
			char_idx += 1
			char_idx %= 4
			select_char(char_idx)

func exit(_next: String) -> void:
	%SelectCharArrow.modulate.a = 0

func select_char(idx: int) -> void:
	var panel: PanelContainer = %PlayerMenuHBox.get_child(idx)
	var x: float = panel.global_position.x + (panel.size.x/2) - (%SelectCharArrow.size.x/2)
	%SelectCharArrow.global_position.x = x
	%SelectCharArrow.modulate.a = 1
