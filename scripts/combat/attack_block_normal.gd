class_name AttackBlockNormal
extends AttackBlock

func on_pressed(distance: float) -> void:
	if distance < perfect_threshold:
		resolved.emit("PERFECT")
	elif distance < great_threshold:
		resolved.emit("GREAT")
	elif distance < good_threshold:
		resolved.emit("GOOD")
	elif distance < ok_threshold:
		resolved.emit("OK")
	else:
		resolved.emit("MISS")

func on_released() -> void:
	pass

func on_missed() -> void:
	resolved.emit("MISS")
