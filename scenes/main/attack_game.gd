extends Control
class_name AttackGame

var is_game_end: bool = false
var stop_spawn: bool = false

const ATTACK: PackedScene = preload("uid://dsid5l6egry4u")
var bottom_y: float
@onready var panel_q: Panel = $HBoxContainer/Panel_Q
@onready var panel_w: Panel = $HBoxContainer/Panel_W
@onready var panel_e: Panel = $HBoxContainer/Panel_E
var queue_q: Array[AttackBlock] = []
var queue_w: Array[AttackBlock] = []
var queue_e: Array[AttackBlock] = []
var panel_char_idx: Array = [0,1,2] #temp

const PERFECT_THRESHOLD: float = 10
const GREAT_THRESHOLD: float = 25
const GOOD_THRESHOLD: float = 50
const OK_THRESHOLD: float = 75

func _ready() -> void:
	bottom_y = panel_q.global_position.y+45

func _process(_delta: float) -> void:
	# Remove from clickable queue
	check_queue(queue_q, 0)
	check_queue(queue_w, 1)
	check_queue(queue_e, 2)
	
	# Key Presses
	click_input("left", 0, queue_q)
	click_input("down", 1, queue_w)
	click_input("right", 2, queue_e)
	
	#if Input.is_key_pressed(KEY_ESCAPE):
		#Game_singleton.change_mode(Game_singleton.Modes.WORLD)
	# Starts game
	if visible and $KeySpawnTimer.is_stopped() and not stop_spawn:
		$KeySpawnTimer.start()
		$GameTimer.start()
	
	# Ends game
	if stop_spawn:
		# Find if all attack blocks are gone
		var blocks_remained: bool = false
		for child in get_children():
			if child is AttackBlock:
				blocks_remained = true
				break
		if not blocks_remained:
			is_game_end = true

func start() -> void:
	is_game_end = false
	stop_spawn = false

func check_queue(queue: Array[AttackBlock], panel_idx):
	if not queue.is_empty():
		if not is_instance_valid(queue.front()):
			queue.pop_front()
		elif queue.front().position.y > bottom_y:
			if visible:
				damage(panel_idx, 10)
			var attack = queue.pop_front()
			attack.kill()

func click_input(action: String, panel_idx: int, queue: Array[AttackBlock]) -> void:
	if Input.is_action_just_pressed(action) and not queue.is_empty():
		var distance = abs(panel_q.global_position.y - queue.front().global_position.y)
		var label_inst = preload("uid://dwf11m2fjyh4f").instantiate()
		label_inst.size.x = panel_q.size.x
		
		if distance < PERFECT_THRESHOLD:
			label_inst.text = "PERFECT"
		elif distance < GREAT_THRESHOLD:
			label_inst.text = "GREAT"
		elif distance < GOOD_THRESHOLD: 
			damage(panel_idx, 1)
			label_inst.text = "GOOD"
		elif distance < OK_THRESHOLD: 
			damage(panel_idx, 5)
			label_inst.text = "OK"
		else:
			damage(panel_idx, 10)
			label_inst.text = "MISS"
		
		match panel_idx:
			0: panel_q.add_child(label_inst)
			1: panel_w.add_child(label_inst)
			2: panel_e.add_child(label_inst)
		
		var attack: AttackBlock = queue.pop_front()
		attack.queue_free()

func damage(panel_idx: int, dmg: int) -> void:
	Game_singleton.party[panel_char_idx[panel_idx]].health -= dmg

func createBlock(panel: Panel) -> Panel:
	var attack_inst: AttackBlock = ATTACK.instantiate()
	attack_inst.position = Vector2(panel.position.x, -50)
	attack_inst.size.x = panel.size.x
	add_child(attack_inst)
	return attack_inst

func set_panel_to_char(panel_idx: int, char_idx: int, color: Color) -> void:
	if not panel_idx in range(0, 3): return
	if not char_idx in range(0, 4): return
	panel_char_idx[panel_idx] = char_idx
	var panel: Panel
	match panel_idx:
		0: panel = panel_q
		1: panel = panel_w
		2: panel = panel_e
	var stylebox := panel.get_theme_stylebox("panel").duplicate()
	stylebox.set("bg_color", Color(color, 0.75))
	panel.add_theme_stylebox_override("panel", stylebox)

func _on_key_spawn_timer_timeout() -> void:
	var panel = randi_range(0, 2)
	match panel:
		0: queue_q.push_back(createBlock(panel_q))
		1: queue_w.push_back(createBlock(panel_w))
		2: queue_e.push_back(createBlock(panel_e))
	if stop_spawn:
		$KeySpawnTimer.stop()

func _on_game_timer_timeout() -> void:
	stop_spawn = true

func toggle_is_game_end(mode: bool) -> void:
	is_game_end = mode
