extends Panel
class_name AttackBlock

@export var speed: float = 8.0
var has_passed: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(_delta: float) -> void:
	global_position += Vector2(0, speed)

func kill() -> void:
	animation_player.play("kill")
