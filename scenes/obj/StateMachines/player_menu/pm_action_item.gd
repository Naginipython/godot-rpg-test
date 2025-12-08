extends PlayerMenuState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var btns: Array[Button] 
var btn_idx: int
var itm_names: Array[String]

func enter(_prev: String) -> void:
	main_grid.visible = false
	btn_idx = 0
	#Sets up buttons (Dynamic)
	setup_btns()
	if not btns.is_empty():
		btns[btn_idx].grab_focus()
		%ItmBtnsContainer.modulate = Color(1,1,1,1)
		# Change the size to make scroll bar irrelevant (to a point (later))
		resize_panel(%ActionContainer)
		# Details container items
		if not is_timer_connected: connect_timer()
		menu.curr_details = btns[btn_idx].text
		start_timer()

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		disable_details()
		change_state.emit(self, "actions")
	elif event.is_action_pressed("select") and not btns[btn_idx].text.contains("x0"):
		disable_details()
		var item_idx: int = menu.items.find_custom(func (x): return x.name == itm_names[btn_idx])
		if item_idx != -1:
			menu.use_item.emit(menu.items.get(item_idx))
			change_state.emit(self, "main")
	
	if %ItmBtnsContainer.modulate.a == 1:
		btn_idx = scroll_menu_buttons_input(event, btns, btn_idx)
		menu.curr_details = itm_names[btn_idx]

func exit(next: String) -> void:
	reset_box(%ItmBtnsContainer)
	if next == "main":
		animation_player.play("CardSwapToMain")

func setup_btns() -> void:
	# Setup buttons (changes when items change
	var items: Array[Item] = menu.items
	var container: VBoxContainer = %ItmBtnsContainer
	btns = []
	if not items.is_empty():
		# Add buttons if needed
		var button = container.get_child(0)
		for i in range(1, items.size()):
			var dup = button.duplicate()
			container.add_child(dup)
		
		# Remove if too many buttons
		if items.size() < container.get_child_count():
			var total = container.get_child_count()
			container.get_child(total-1).queue_free()
		
		# Get all buttons in array
		for child in container.get_children():
			if child is Button:
				btns.push_back(child)
		
		# Rename buttons
		itm_names = []
		for i in range(0, items.size()):
			btns[i].text = items[i].name + " x" + str(items[i].quantity)
			itm_names.push_back(items[i].name)
	else:
		print("huh")
		print(container)
		container.modulate.a = 0
