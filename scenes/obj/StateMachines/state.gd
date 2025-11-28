class_name State
extends Node

var entity: Node

@warning_ignore("unused_signal")
signal change_state(state: State, new_state: String)

func enter(_prev: String) -> void:
	pass

func unhandled_input(event: InputEvent) -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func exit(_next: String) -> void:
	pass
