extends PlayerMenuState

# actin:attack:
	# when entered, display attacks, resize thing
	# when exit, resize thing to normal
	# process: wasd control buttons
	
@onready var player_menu: PlayerMenu = $"../.."
@onready var actions_panel: PanelContainer = %ActionsPanel
@onready var main_grid: GridContainer = %MainGrid
@onready var secondary_container: ScrollContainer = %SecondaryContainer
@onready var btns_container: VBoxContainer = %BtnsContainer
@onready var button: Button = %Button
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var btns: Array[Button]
var btn_idx: int
var attacks: PackedStringArray

func enter(_prev: String) -> void:
	main_grid.visible = false
	secondary_container.visible = true
	btn_idx = 0
	if attacks.is_empty():
		attacks = Game_singleton.get_attacks(player_menu.char_id)
	
		# Add buttons
		if attacks.is_empty(): return
		button.text = attacks[0]
		btns.push_back(button)
		for i in range(1, attacks.size()):
			var dup = button.duplicate()
			dup.text = attacks[i]
			btns_container.add_child(dup)
			btns.push_back(dup)
	
	# Get all buttons in array
	#for child in btns_container.get_children():
		#if child is Button:
			#btns.push_back(child)
	btns[btn_idx].grab_focus()
	
	# Change the size to make scroll bar irrelevant (to a point (later))
	await get_tree().process_frame
	var visible_height: float = secondary_container.get_size().y
	var total_height: float = secondary_container.get_v_scroll_bar().max_value
	var missing_height: float = max(total_height - visible_height, 0)
	actions_panel.size.y += missing_height
	actions_panel.position.y -= missing_height

func process(_delta: float) -> void:
	# Makes sure ScrollContainer gets margins
	var scroll: VScrollBar = secondary_container.get_v_scroll_bar()
	if btn_idx == btns.size()-1:
		scroll.value = scroll.max_value
	if btn_idx == 0:
		scroll.value = 0
	
	if Input.is_action_just_pressed("return"):
		change_state.emit(self, "actions")
	if Input.is_action_just_pressed("select"):
		player_menu.use_attack(btns[btn_idx].text)
		change_state.emit(self, "main")
	attack_selection()

func exit(next: String) -> void:
	if next == "main":
		animation_player.play("CardSwapToMain")
	secondary_container.visible = false
	main_grid.visible = true
	actions_panel.size.y = 100
	actions_panel.position.y = 0

func attack_selection() -> void:
	if Input.is_action_just_pressed("down"):
		btn_idx = (btn_idx+1) %btns.size()
		btns[btn_idx].grab_focus()
	if Input.is_action_just_pressed("up"):
		if btn_idx-1 == -1:
			btn_idx = btns.size()-1
		else:
			btn_idx = (btn_idx-1) %btns.size()
		btns[btn_idx].grab_focus()
