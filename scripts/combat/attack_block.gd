class_name AttackBlock
extends Panel

signal resolved(result: String)
signal feedback(s: String)

@export var speed: float = 500.0
@export var block_type: AttackGame.Block
@export var perfect_threshold: float = 10.0
@export var great_threshold: float = 25.0
@export var good_threshold: float = 50.0
@export var ok_threshold: float = 75.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var has_passed: bool = false

func _physics_process(delta: float) -> void:
	global_position.y += speed * delta

func on_pressed(_distance: float) -> void:
	pass

func on_released() -> void:
	pass

func on_missed() -> void:
	resolved.emit("MISS")

func kill() -> void:
	animation_player.play("kill")
