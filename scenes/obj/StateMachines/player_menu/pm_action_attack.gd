extends PlayerMenuState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var btns: Array[Button] 
var btn_idx: int

func enter(_prev: String) -> void:
	main_grid.visible = false
	btn_idx = 0
	# Get all buttons in array
	btns = get_buttons(%AtkBtnsContainer)
	btns[btn_idx].grab_focus()
	# Change the size to make scroll bar irrelevant (to a point (later))
	resize_panel(%AttackContainer)

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		change_state.emit(self, "actions")
	elif event.is_action_pressed("select"):
		menu.use_attack.emit(menu.attacks[btns[btn_idx].text])
		change_state.emit(self, "main")
	
	btn_idx = scroll_menu_buttons_input(event, btns, btn_idx)

func exit(next: String) -> void:
	reset_box(%AtkBtnsContainer)
	if next == "main":
		animation_player.play("CardSwapToMain")
