extends PauseMenuState

var char_idx = 0
var menu: PanelContainer
var new_menu: PanelContainer
@export var stat_menu_template: PanelContainer

func enter(_prev: String) -> void:
	char_idx = pause_menu.char_selected
	menu = %PlayerMenuHBox.get_child(char_idx)
	
	new_menu = menu.duplicate()
	new_menu.global_position = menu.global_position + Vector2(10,0)
	new_menu.size = Vector2(275, 170)
	new_menu.init_menu(menu.character_data)
	pause_menu.add_child(new_menu)
	menu.modulate.a = 0
	
	var tween: Tween = create_tween()
	tween.tween_property(new_menu, "global_position", stat_menu_template.global_position, 0.2)
	#move PlayerMenuHBox down a lil (cuetness factor)
	var playerbox: HBoxContainer = %PlayerMenuHBox
	tween.tween_property(playerbox, "global_position", Vector2(0, 570.0 + 100), 0.1)
	tween.tween_property(new_menu, "size", stat_menu_template.size, 0.1)
	
	#edit stats
	new_menu.set_stats()
	#highlight area (maybe make it so L/R change submenu, U/D goes through?

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		get_viewport().set_input_as_handled()
		change_state.emit(self, "charselect")

func exit(_next: String) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(new_menu, "size", menu.size, 0.1)
	var playerbox: HBoxContainer = %PlayerMenuHBox
	tween.tween_property(playerbox, "global_position", Vector2(0, 570.0), 0.1)
	tween.chain()
	tween.tween_property(new_menu, "global_position", menu.global_position, 0.2)
	await tween.finished
	new_menu.queue_free()
	menu.modulate.a = 1
