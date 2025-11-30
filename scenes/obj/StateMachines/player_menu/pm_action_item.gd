extends PlayerMenuState

@onready var player_menu: PlayerMenu = $"../.."
@onready var actions_panel: PanelContainer = %ActionsPanel
@onready var main_grid: GridContainer = %MainGrid
@onready var secondary_container: ScrollContainer = %SecondaryContainer
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

signal use_item(item: String)

var btns: Array[Button] 
var btn_idx: int

func enter(_prev: String) -> void:
	main_grid.visible = false
	btn_idx = 0
	
	setup_btns()
	
	btns[btn_idx].grab_focus()
	%ItmBtnsContainer.visible = true
	
	# Change the size to make scroll bar irrelevant (to a point (later))
	var visible_height: float = secondary_container.get_size().y
	var total_height: float = secondary_container.get_v_scroll_bar().max_value
	var missing_height: float = max(total_height - visible_height, 0)
	actions_panel.size.y += missing_height
	actions_panel.position.y -= missing_height

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		change_state.emit(self, "actions")
	elif event.is_action_pressed("select"):
		#player_menu.use_item(player_menu.items[btns[btn_idx].text])
		use_item.emit(btns[btn_idx].text)
		change_state.emit(self, "main")

func process(_delta: float) -> void:
	# Makes sure ScrollContainer gets margins
	var scroll: VScrollBar = secondary_container.get_v_scroll_bar()
	if btn_idx == btns.size()-1:
		scroll.value = scroll.max_value
	if btn_idx == 0:
		scroll.value = 0
	
	item_selection()

func exit(next: String) -> void:
	%ItmBtnsContainer.visible = false
	main_grid.visible = true
	actions_panel.size.y = 100
	actions_panel.position.y = 0
	if next == "main":
		animation_player.play("CardSwapToMain")

func item_selection() -> void:
	if Input.is_action_just_pressed("down"):
		btn_idx = (btn_idx+1) %btns.size()
		btns[btn_idx].grab_focus()
	if Input.is_action_just_pressed("up"):
		if btn_idx-1 == -1:
			btn_idx = btns.size()-1
		else:
			btn_idx = (btn_idx-1) %btns.size()
		btns[btn_idx].grab_focus()

func setup_btns() -> void:
	# Setup buttons (changes when items change
	var items: Array[Item] = player_menu.items
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
