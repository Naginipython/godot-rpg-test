class_name AttackGame
extends Control

signal attack_ended

@export var attack_block_normal: PackedScene
@export var attack_block_hold: PackedScene
@export var result_label: PackedScene
var threshold: float

var attack_plan

@onready var panel_q: Panel = $HBoxContainer/PanelQ
@onready var panel_w: Panel = $HBoxContainer/PanelW
@onready var panel_e: Panel = $HBoxContainer/PanelE
@onready var tempo: Timer = $Tempo

var queue_q: Array[AttackBlock] = []
var queue_w: Array[AttackBlock] = []
var queue_e: Array[AttackBlock] = []
var panel_char_idx: Array[int] = [0,1,2] # Set in set_panel_to_char every attack
var enabled_panels: Array[bool] = [false, false, false] # Dead chars

enum Block {
	Normal, Hold, Multihit
}
enum Lane {
	Q, W, E
}

const EXAMPLE_NORMAL = [
	[[Block.Normal, Lane.Q]],
	[[Block.Normal, Lane.W]],
	[[Block.Normal, Lane.E]],
	[],
	[[Block.Normal, Lane.E]],
	[[Block.Normal, Lane.W]],
	[[Block.Normal, Lane.Q], [Block.Normal, Lane.E]],
]

const EXAMPLE_HOLD = [
	[[Block.Hold, Lane.Q, 4]],
	[],
	[],
	[],
	[[Block.Normal, Lane.E]],
]

func _ready() -> void:
	threshold = panel_q.global_position.y + 45
	attack_plan = EXAMPLE_HOLD.duplicate(true)
	tempo.start()

func _process(_delta: float) -> void:
	check_attack_end()
	
	check_missed(queue_q)
	check_missed(queue_w)
	check_missed(queue_e)
	
	if Input.is_action_just_pressed("left"):
		key_clicked(0, queue_q)
	if Input.is_action_just_pressed("down"):
		key_clicked(1, queue_w)
	if Input.is_action_just_pressed("right"):
		key_clicked(2, queue_e)
	
	if Input.is_action_just_released("left"):
		key_released(queue_q)
	if Input.is_action_just_released("down"):
		key_released(queue_w)
	if Input.is_action_just_released("right"):
		key_released(queue_e)

func check_missed(queue: Array[AttackBlock]):
	if not queue.is_empty():
		if queue.front().position.y > threshold:
			queue.front().on_missed()

func key_clicked(_idx: int, queue: Array[AttackBlock]) -> void:
	if queue.is_empty():
		return
	var block: AttackBlock = queue.front()
	var distance = abs(panel_q.global_position.y - queue.front().global_position.y)
	block.on_pressed(distance)

func key_released(queue: Array[AttackBlock]) -> void:
	if not queue.is_empty():
		queue.front().on_released()

func damage(idx: int, _dmg: int) -> void:
	print("damage idx: ", idx)
	#Game.party[panel_char_idx[idx]].health -= dmg

func set_panel_to_char(panel_idx: int, char_idx: int) -> void:
	# Todo: setup entire party to panel_idx here, instead of the other place
	if not panel_idx in range(0, 3): return
	if not char_idx in range(0, 4): return
	panel_char_idx[panel_idx] = char_idx
	enabled_panels[panel_idx] = true

func check_attack_end():
	if attack_plan.is_empty() and queue_q.is_empty() and queue_w.is_empty() and queue_e.is_empty():
		tempo.stop()
		attack_ended.emit()

func _on_key_spawn_timer_timeout() -> void:
	if attack_plan.is_empty():
		return
	
	var row = attack_plan.pop_front()
	for item in row:
		var queue: Array[AttackBlock]
		var panel: Panel
		var lane: int = item[1]
		
		match lane:
			Lane.Q:
				queue = queue_q
				panel = panel_q
			Lane.W:
				queue = queue_w
				panel = panel_w
			Lane.E:
				queue = queue_e
				panel = panel_e
			_:
				push_error("Unknown attack lane: %s" % lane)
				continue
		
		match item[0]:
			Block.Normal:
				var block: AttackBlockNormal = attack_block_normal.instantiate()
				block.global_position = Vector2(panel.global_position.x, global_position.y - block.size.y)
				block.size.x = panel.size.x
				block.feedback.connect(_on_block_feedback.bind(lane))
				block.resolved.connect(_on_block_resolved.bind(block, queue, lane))
				add_child(block)
				queue.push_back(block)
			Block.Hold:
				var block: AttackBlockHold = attack_block_hold.instantiate()
				block.global_position = Vector2(panel.global_position.x, global_position.y - block.size.y)
				block.size.x = panel.size.x
				block.feedback.connect(_on_block_feedback.bind(lane))
				block.resolved.connect(_on_block_resolved.bind(block, queue, lane))
				add_child(block)
				block.configure(int(item[2]), tempo.wait_time, threshold)
				queue.push_back(block)
			_:
				push_error("Attack block type not implemented: %s" % item[0])

func _on_block_feedback(feedback: String, lane: int) -> void:
	var panels: Array[Panel] = [panel_q, panel_w, panel_e]
	var panel := panels[lane]
	var label: Label = result_label.instantiate()
	label.text = feedback
	label.size.x = panel.size.x
	panel.add_child(label)

func _on_block_resolved(result: String, block: AttackBlock, queue: Array[AttackBlock], lane: int) -> void:
	queue.erase(block)
	
	# TODO: custom damage from enemy type
	damage(lane, 10)
	
	_on_block_feedback(result, lane)
	
	if result == "MISS":
		print("MISS, lane ", lane)
	else:
		print("HIT: lane ", lane, " with result: ", result)

	block.kill()
