extends CharacterBody2D
class_name Player

@onready var head_label: Label = $HeadLabel

var npcs_in_range: Array[Npc] = []
var facing_npc: Npc
var cutscene_area: Area2D
var dialogue: Resource
var cue: String
var scripted_movement_active: bool = false

@export_group("Movement Values")
@export var move_distance: float = 16.0
@export var duration: float = 0.2
var speed: float = move_distance / duration

@export_group("Other")
@export var state_machine: StateMachine = null

func _ready() -> void:
	Game.register_player(self)

func _exit_tree() -> void:
	Game.unregister_player(self)

func surprised() -> void:
	head_label.show()
	await get_tree().create_timer(0.5).timeout
	head_label.hide()

func start_talking(_dialogue: Resource, _cue: String) -> void:
	dialogue = _dialogue
	cue = _cue

func end_talking() -> void:
	dialogue = null
	cue = ""

func move_tiles(x: int, y: int) -> void:
	if scripted_movement_active:
		push_error("Player.move_tiles() cannot run while another scripted move is active.")
		return

	scripted_movement_active = true
	for _i in range(abs(x)):
		await move(Vector2.RIGHT if x > 0 else Vector2.LEFT)
	for _i in range(abs(y)):
		await move(Vector2.DOWN if y > 0 else Vector2.UP)
	scripted_movement_active = false

func move(direction: Vector2) -> void:
	var motion := direction * move_distance
	if test_move(global_transform, motion):
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", global_position + motion, duration)
	await tween.finished
