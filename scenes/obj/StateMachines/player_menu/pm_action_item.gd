extends PlayerMenuState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

signal use_item(item: String)

var btns: Array[Button] 
var btn_idx: int

func enter(_prev: String) -> void:
	main_grid.visible = false
	btn_idx = 0
	#Sets up buttons (Dynamic)
	setup_btns()
	btns[btn_idx].grab_focus()
	%ItmBtnsContainer.modulate = Color(1,1,1,1)
	# Change the size to make scroll bar irrelevant (to a point (later))
	resize_panel(%ActionContainer)

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		change_state.emit(self, "actions")
	elif event.is_action_pressed("select"):
		menu.use_item.emit(menu.items[btn_idx])
		change_state.emit(self, "main")
	
	btn_idx = scroll_menu_buttons_input(event, btns, btn_idx)

func exit(next: String) -> void:
	reset_box(%ItmBtnsContainer)
	if next == "main":
		animation_player.play("CardSwapToMain")

func setup_btns() -> void:
	# Setup buttons (changes when items change
	var items: Array[Item] = menu.items
	var container = %ItmBtnsContainer
	if not items.is_empty():
		# Add buttons if needed
		var button = container.get_child(0)
		for i in range(1, items.size()):
			var dup = button.duplicate()
			#dup.text = items[i].name + " x" + str(items[i].quantity)
			container.add_child(dup)
		
		# Remove if too many buttons
		if items.size() < container.get_child_count():
			var total = container.get_child_count()
			container.get_child(total-1).queue_free()
		
		# Get all buttons in array
		btns = []
		for child in container.get_children():
			if child is Button:
				btns.push_back(child)
		
		# Rename buttons
		for i in range(0, items.size()):
			btns[i].text = items[i].name + " x" + str(items[i].quantity)
