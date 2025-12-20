extends Sprite2D
class_name Npc

func toggle_hint_visibility(vis: bool) -> void:
	$HintLabel.visible = vis

@export var dialogue: Dictionary[StoryManager.StoryPoint, Conversation]
