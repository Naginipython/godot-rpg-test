class_name PlayerMenuState
extends Node

signal change_state(state: PlayerMenuState, new_state: String)

@onready var menu: PlayerMenu = get_owner()

func _ready() -> void:
	menu.swap_menus.connect(swap_menus)

# Sets up state
func enter(_prev: String) -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func exit(_next: String) -> void:
	pass

# Common methods

func swap_menus(new_menu: String) -> void:
	change_state.emit(self, new_menu)
