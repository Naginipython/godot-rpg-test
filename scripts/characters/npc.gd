class_name Npc
extends Sprite2D

@export var label: Label

@export var dialogue: Resource
@export var dialogue_start: String

func toggle_hint_visibility(vis: bool) -> void:
	label.visible = vis
