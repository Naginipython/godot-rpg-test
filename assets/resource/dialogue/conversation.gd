extends Resource
class_name Conversation

@export var lines: Array[DialogueLine]

func _init(_lines: Array[DialogueLine] = []) -> void:
	lines = _lines
