extends Node

@export var init_state: PlayerState

var curr_state: PlayerState
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			child.change_state.connect(change_state)
	if init_state:
		curr_state = init_state
		init_state.enter("")

func _process(delta: float) -> void:
	if curr_state:
		curr_state.process(delta)
func _physics_process(delta: float) -> void:
	if curr_state:
		curr_state.physics_process(delta)

func change_state(state: PlayerState, new_state: String) -> void:
	if state != curr_state: return
	
	var to_change = states.get(new_state.to_lower())
	if !to_change: return
	
	var prev = state.name.to_lower()
	if curr_state: curr_state.exit(new_state)
	
	to_change.enter(prev)
	curr_state = to_change
