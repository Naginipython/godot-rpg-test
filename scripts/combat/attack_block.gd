class_name AttackBlock
extends Panel

signal resolved(result: String)
signal feedback(s: String)

@export var speed: float = 500.0
@export var block_type: AttackGame.Block
@export var perfect_threshold: float = 15.0
@export var great_threshold: float = 30.0
@export var good_threshold: float = 50.0
@export var ok_threshold: float = 75.0

var attack_game: AttackGame
var spawn_y: float
var spawn_time: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var has_passed: bool = false

func _physics_process(_delta: float) -> void:
	global_position.y = reference_y()

func setup(game: AttackGame, scheduled_time: float) -> void:
	attack_game = game
	spawn_y = global_position.y
	spawn_time = scheduled_time

func on_pressed(_distance: float) -> void:
	pass

func on_released() -> void:
	pass

func on_missed() -> void:
	resolved.emit("MISS")

func kill() -> void:
	animation_player.play("kill")

func reference_y() -> float:
	return spawn_y + speed * (attack_game.song_time - spawn_time)
