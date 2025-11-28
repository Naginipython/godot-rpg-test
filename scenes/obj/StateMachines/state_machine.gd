class_name StateMachine
extends Node

@export var init_state: State

var curr_state: State
var states: Dictionary = {}

func _ready() -> void:
	await owner.ready
	
	for child in get_children():
		if child is State:
			child.entity = owner #Sets State to the node owner
			states[child.name.to_lower()] = child
			child.change_state.connect(change_state)
	if init_state:
		curr_state = init_state
		init_state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	if curr_state:
		curr_state.unhandled_input(event)

func _process(delta: float) -> void:
	if curr_state:
		curr_state.process(delta)
func _physics_process(delta: float) -> void:
	if curr_state:
		curr_state.physics_process(delta)

func change_state(state: State, new_state: String) -> void:
	if state != curr_state: return
	
	var to_change = states.get(new_state.to_lower())
	if !to_change: return
	
	var prev = state.name.to_lower()
	if curr_state: curr_state.exit(new_state)
	
	to_change.enter(prev)
	curr_state = to_change
