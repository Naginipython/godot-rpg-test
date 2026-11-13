class_name AttackBlockHold
extends AttackBlock

var hold_length: float
var hit_y: float
var is_holding: bool = false

@onready var hold_bar: Panel = $HoldBar
@onready var feedback_timer: Timer = $FeedbackTimer

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if is_holding and global_position.y - hold_length >= hit_y:
		_finish_hold("PERFECT")

func configure(beats:int, beat_seconds: float, target_y: float) -> void:
	hold_length = speed * beats * beat_seconds
	hit_y = target_y
	hold_bar.position = Vector2(0, -hold_length)
	hold_bar.size = Vector2(size.x, hold_length)

func on_pressed(distance: float) -> void:
	if distance < perfect_threshold:
		feedback.emit("PERFECT")
	elif distance < great_threshold:
		feedback.emit("GREAT")
	elif distance < good_threshold:
		feedback.emit("GOOD")
	elif distance < ok_threshold:
		feedback.emit("OK")
	else:
		feedback.emit("MISS")
		return
	is_holding = true
	feedback_timer.start()

func on_released() -> void:
	if not is_holding:
		return
	
	var tail_y: float = global_position.y - hold_length
	if tail_y >= hit_y:
		_finish_hold("PERFECT")
	else:
		_finish_hold("MISS")

func on_missed() -> void:
	if not is_holding:
		resolved.emit("MISS")

func _finish_hold(result: String) -> void:
	if not is_holding:
		return
	
	is_holding = true
	feedback_timer.stop()
	resolved.emit(result)

func _on_feedback_timer_timeout() -> void:
	feedback.emit("PERFECT")
