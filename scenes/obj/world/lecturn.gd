extends Npc
class_name Lecturn

@export var options: PackedStringArray = ["Save Game", "Change Party"]

func apply_option(option: String) -> void:
	if option.contains("Save"):
		print("game saved (temp)")
	elif option.contains("Change"):
		print("changing party")
