extends Control
class_name SwapMenu

enum SwapStates {
	SelectSwap, SelectActive, SelectOption, Compare
}
var state: SwapStates = SwapStates.SelectSwap

var chars: Array[CharacterData]
var active: Array[CharacterData]
@onready var char_container: VBoxContainer = %CharContainer
@onready var swap_char_container: VBoxContainer = %SwapCharContainer
@onready var options_container: VBoxContainer = $OptionsContainer

var swap_char_idx: int = 0
var active_char_idx: int = 0
var option_idx: int = 0

var dup: SwapMenuCharBox

func enable() -> void:
	# presents
	swap_char_idx = 0
	state = SwapStates.SelectSwap
	%ActiveSelectLabel.visible = false
	options_container.visible = false
	revert_cute_indent()
	
	# get data
	chars = GameManager.characters.values()
	active = GameManager.party
	# Remove Data
	for child in char_container.get_children():
		char_container.remove_child(child)
	for child in swap_char_container.get_children():
		swap_char_container.remove_child(child)
	# Set active chars
	for ch in active:
		var charbox: SwapMenuCharBox = preload("uid://d4m1on3wn256l").instantiate()
		charbox.set_data(ch)
		char_container.add_child(charbox)
	# Set unactive chars
	for ch in chars:
		if not ch.active:
			var swapbox: SwapMenuSwapCharBox = preload("uid://dh8l7ch4480bs").instantiate()
			swapbox.set_data(ch)
			swap_char_container.add_child(swapbox)
	if swap_char_container.get_children().size() > 0:
		swap_char_container.get_child(0).is_hovered(true)
	
	# Visible
	visible = true

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused and visible:
		match state:
			SwapStates.SelectSwap:
				input_state_select_swap(event)
			SwapStates.SelectActive:
				input_state_select_active(event)
			SwapStates.SelectOption:
				input_state_select_options(event)

# ----- Select Swap state -----
func input_state_select_swap(event: InputEvent) -> void:
	if event.is_action_pressed("down"):
		swap_char_idx += 1
		if swap_char_idx >= swap_char_container.get_children().size():
			swap_char_idx = 0
		set_new_swap_selected(swap_char_idx)
	if event.is_action_pressed("up"):
		swap_char_idx -= 1
		if swap_char_idx <= -1: 
			swap_char_idx = swap_char_container.get_children().size()-1
		set_new_swap_selected(swap_char_idx)
	if event.is_action_pressed("select"):
		%ActiveSelectLabel.visible = true
		state = SwapStates.SelectActive
		active_char_idx = 0
		set_new_active_selected(active_char_idx)
	if event.is_action_pressed("return"):
		get_viewport().set_input_as_handled()
		visible = false
		get_tree().paused = false

func set_new_swap_selected(idx: int) -> void:
	for child in swap_char_container.get_children():
		if child is SwapMenuSwapCharBox:
			child.is_hovered(false)
	var swap: SwapMenuSwapCharBox = swap_char_container.get_child(idx)
	swap.is_hovered(true)

# ----- Select Active state -----
func input_state_select_active(event: InputEvent) -> void:
	if event.is_action_pressed("down"):
		active_char_idx += 1
		if active_char_idx >= char_container.get_children().size():
			active_char_idx = 0
		set_new_active_selected(active_char_idx)
	if event.is_action_pressed("up"):
		active_char_idx -= 1
		if active_char_idx <= -1: 
			active_char_idx = char_container.get_children().size()-1
		option_idx = 0
		set_new_active_selected(active_char_idx)
	if event.is_action_pressed("select"):
		options_container.visible = true
		%ActiveSelectLabel.visible = false
		state = SwapStates.SelectOption
		open_swap_options(active_char_idx)
		options_container.get_child(0).grab_focus()
	if event.is_action_pressed("return"):
		state = SwapStates.SelectSwap
		%ActiveSelectLabel.visible = false
		revert_cute_indent()

func set_new_active_selected(idx: int) -> void:
	var arrow = %ActiveSelectLabel
	var box: SwapMenuCharBox = char_container.get_child(idx)
	revert_cute_indent()
	# Cute Boxes
	dup = box.duplicate()
	dup.set_data(GameManager.characters[box.char_id])
	dup.global_position = box.global_position + Vector2(25, 0)
	$".".add_child(dup)
	box.modulate.a = 0
	# main
	arrow.global_position.y = box.global_position.y - (arrow.size.y/2) + (box.size.y/2)

func revert_cute_indent() -> void:
	if dup:
		for child in char_container.get_children():
			if child.char_id == dup.char_id:
				child.modulate.a = 1
		$".".remove_child(dup)
		dup = null

# ----- Select Options state -----
func input_state_select_options(event: InputEvent) -> void:
	if event.is_action_pressed("down"):
		option_idx += 1
		if option_idx >= options_container.get_children().size():
			option_idx = 0
		options_container.get_child(option_idx).grab_focus()
	if event.is_action_pressed("up"):
		option_idx -= 1
		if option_idx <= -1: 
			option_idx = options_container.get_children().size()-1
		options_container.get_child(option_idx).grab_focus()
	if event.is_action_pressed("select"):
		select_option(option_idx)
	if event.is_action_pressed("return"):
		%ActiveSelectLabel.visible = true
		options_container.visible = false
		state = SwapStates.SelectActive

func open_swap_options(idx: int) -> void:
	var box: SwapMenuCharBox = char_container.get_child(idx)
	options_container.global_position.y = box.global_position.y -\
		(options_container.size.y/2) + (box.size.y/2)

func select_option(idx: int) -> void:
	var new_box: SwapMenuSwapCharBox = swap_char_container.get_child(swap_char_idx)
	match idx:
		0:  # Old char
			active[active_char_idx].active = false
			active.remove_at(active_char_idx)
			# New char
			var new_char: CharacterData = GameManager.get_char_data(new_box.char_id)
			new_char.active = true
			active.push_back(new_char)
			GameManager.sort_party()
			# Reset
			enable()
	# Select Swap
		# Changes character active & party
		# Updates this screen
	# Select swap & return items
		# same as above, changes item status
	# Select Compare
		# Brings up menu where it shows both data (new state)
	pass
