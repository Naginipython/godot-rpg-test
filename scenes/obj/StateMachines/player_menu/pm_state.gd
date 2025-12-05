class_name PlayerMenuState
extends State

var menu: PlayerMenu:
	get: return entity as PlayerMenu

# Common methods

func swap_menus(new_menu: String) -> void:
	change_state.emit(self, new_menu)



@onready var main_grid: GridContainer = %MainGrid
@onready var actions_panel: PanelContainer = %ActionsPanel

func get_buttons(container: VBoxContainer) -> Array[Button]:
	var btns: Array[Button] = []
	#container.visible = true
	container.modulate = Color(1,1,1,1)
	for child in container.get_children():
		if child is Button:
			btns.push_back(child)
	return btns

func resize_panel(container: ScrollContainer) -> void:
	var visible_height: float = container.get_size().y
	var total_height: float = container.get_v_scroll_bar().max_value
	var missing_height: float = max(total_height - visible_height, 0)
	actions_panel.size.y += missing_height
	actions_panel.position.y -= missing_height

func scroll_menu_buttons_input(event: InputEvent, btns: Array[Button], btn_idx: int) -> int:
	#var btn_idx = idx
	if event.is_action_pressed("down"):
		btn_idx = (btn_idx+1) %btns.size()
		btns[btn_idx].grab_focus()
	if event.is_action_pressed("up"):
		if btn_idx-1 == -1:
			btn_idx = btns.size()-1
		else:
			btn_idx = (btn_idx-1) %btns.size()
		btns[btn_idx].grab_focus()
	return btn_idx

func reset_box(container: VBoxContainer) -> void:
	container.modulate = Color(1,1,1,0)
	main_grid.visible = true
	actions_panel.size.y = 100
	actions_panel.position.y = 0
