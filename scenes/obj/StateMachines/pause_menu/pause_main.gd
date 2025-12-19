extends PauseMenuState

@export var animation_player: AnimationPlayer
@export var char_btn: Button
@export var itm_btn: Button
@export var idk_btn: Button
@export var save_temp_btn: Button

var selected_idx: int = 0
var selected_char_idx: int = 0
var pick_char: bool = false

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		get_viewport().set_input_as_handled()
		toggle_paused()
	if get_tree().paused:
		if event.is_action_pressed("select"):
			push_btn(selected_idx)
		if event.is_action_pressed("left"):
			selected_idx -= 1
			if selected_idx < 0: selected_idx = 3
			select_menu_item(selected_idx)
		elif event.is_action_pressed("right"):
			selected_idx += 1
			selected_idx %= 4
			select_menu_item(selected_idx)

func toggle_paused() -> void:
	get_tree().paused = not get_tree().paused
	if get_tree().paused: 
		animation_player.play("menu_open")
		selected_idx = 0
		select_menu_item(selected_idx)
	else: 
		animation_player.play("menu_close")

func select_menu_item(idx: int) -> void:
	match idx:
		0: char_btn.grab_focus()
		1: itm_btn.grab_focus()
		2: idk_btn.grab_focus()
		3: save_temp_btn.grab_focus()

func push_btn(idx: int) -> void:
	match idx:
		0: char_btn.emit_signal("pressed")
		1: itm_btn.emit_signal("pressed")
		2: idk_btn.emit_signal("pressed")
		3: save_temp_btn.emit_signal("pressed")

func _on_save_btn_temp_pressed() -> void:
	print("testsavedpress")
	if pause_menu.player:
		GameManager.player_pos = GameManager.worldpos_to_tilepos(pause_menu.player.global_position)
	#SaveManager.save_game()

func _on_char_btn_pressed() -> void:
	change_state.emit(self, "charselect")
