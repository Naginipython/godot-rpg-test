class_name AttackBlockMulti
extends AttackBlock

var health: int = 2
var hits_completed: int = 0
var backtrack_speed: float = 1000.0
var tempo_distance: float
var needs_move: bool = false
var target_y: float

@onready var health_label: Label = $HealthLabel

func _physics_process(delta: float) -> void:
	var desired_y = reference_y() - hits_completed * tempo_distance
	
	if needs_move:
		global_position.y = move_toward(
			global_position.y,
			desired_y,
			backtrack_speed * delta
		)
		if global_position.y == desired_y:
			needs_move = false
	else:
		global_position.y = desired_y

func configure(_health: int, beat_seconds: float) -> void:
	tempo_distance = speed * beat_seconds
	health = _health
	health_label.text = str(health)

func on_pressed(distance: float) -> void:
	var rating: String
	
	if distance < perfect_threshold:
		rating = "PERFECT"
	elif distance < great_threshold:
		rating = "GREAT"
	elif distance < good_threshold:
		rating = "GOOD"
	elif distance < ok_threshold:
		rating = "OK"
	else:
		resolved.emit("MISS")
		return
		
	health -= 1
	health_label.text = str(health)

	if health < 0:
		resolved.emit(rating)
		return

	feedback.emit(rating)
	hits_completed += 1
	needs_move = true

func on_missed() -> void:
	resolved.emit("MISS")
