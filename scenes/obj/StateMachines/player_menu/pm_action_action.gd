extends PlayerMenuState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var btns: Array[Button]
var btn_idx: int

func enter(_prev: String) -> void:
	main_grid.visible = false
	btn_idx = 0
	# Get all buttons in array
	btns = get_buttons(%ActBtnsContainer)
	btns[btn_idx].grab_focus()
	# Change the size to make scroll bar irrelevant (to a point (later))
	resize_panel(%ActionContainer)
	# Details container items
	menu.curr_details = btns[btn_idx].text
	start_timer()

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		disable_details()
		change_state.emit(self, "actions")
	elif event.is_action_pressed("select"):
		disable_details()
		menu.use_action.emit(menu.actions[btns[btn_idx].text])
		change_state.emit(self, "main")
	
	if %ActBtnsContainer.modulate.a == 1:
		btn_idx = scroll_menu_buttons_input(event, btns, btn_idx)
		menu.curr_details = btns[btn_idx].text

func exit(next: String) -> void:
	reset_box(%ActBtnsContainer)
	if next == "main":
		animation_player.play("CardSwapToMain")
