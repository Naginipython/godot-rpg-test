class_name PlayerState
extends Node

signal change_state(state: PlayerState, new_state: String)

@onready var player: Player = get_owner()

func _ready() -> void:
	pass

# Sets up state
func enter(_prev: String) -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func exit(_next: String) -> void:
	pass
