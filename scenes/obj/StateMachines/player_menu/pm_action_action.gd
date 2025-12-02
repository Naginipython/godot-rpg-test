extends PlayerMenuState

@onready var player_menu: PlayerMenu = $"../.."
@onready var actions_panel: PanelContainer = %ActionsPanel
@onready var main_grid: GridContainer = %MainGrid
@onready var secondary_container: ScrollContainer = %SecondaryContainer
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var btns: Array[Button]
var btn_idx: int

func enter(_prev: String) -> void:
	main_grid.visible = false
	btn_idx = 0
	
	# Get all buttons in array
	%ActBtnsContainer.visible = true
	for child in %ActBtnsContainer.get_children():
		if child is Button:
			btns.push_back(child)
	btns[btn_idx].grab_focus()
	
	# Change the size to make scroll bar irrelevant (to a point (later))
	var visible_height: float = secondary_container.get_size().y
	var total_height: float = secondary_container.get_v_scroll_bar().max_value
	var missing_height: float = max(total_height - visible_height, 0)
	actions_panel.size.y += missing_height
	actions_panel.position.y -= missing_height

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		change_state.emit(self, "actions")
	if event.is_action_pressed("select"):
		menu.use_action.emit(menu.actions[btns[btn_idx].text])
		change_state.emit(self, "main")

func process(_delta: float) -> void:
	# Makes sure ScrollContainer gets margins
	var scroll: VScrollBar = secondary_container.get_v_scroll_bar()
	if btn_idx == btns.size()-1:
		scroll.value = scroll.max_value
	if btn_idx == 0:
		scroll.value = 0
	
	actions_selection()

func exit(next: String) -> void:
	%ActBtnsContainer.visible = false
	main_grid.visible = true
	actions_panel.size.y = 100
	actions_panel.position.y = 0
	if next == "main":
		animation_player.play("CardSwapToMain")

func actions_selection() -> void:
	if Input.is_action_just_pressed("down"):
		btn_idx = (btn_idx+1) %btns.size()
		btns[btn_idx].grab_focus()
	if Input.is_action_just_pressed("up"):
		if btn_idx-1 == -1:
			btn_idx = btns.size()-1
		else:
			btn_idx = (btn_idx-1) %btns.size()
		btns[btn_idx].grab_focus()
