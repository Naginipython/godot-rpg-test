extends PlayerState

var is_moving: bool = false
var target_pos: Vector2
var prev_pos: Vector2
var facing_dir: Vector2 = Vector2.DOWN
var input_dir: Vector2

var transition_to_cutscene: bool = false

func enter(_prev: String) -> void:
	target_pos = player.global_position
	transition_to_cutscene = false

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"): # and interact_cooldown.is_stopped():
		interact()

func process(_delta: float) -> void:
	if player.dialogue:
		change_state.emit(self, "talking")

func physics_process(delta: float) -> void:
	check_running()
	handle_move(delta)

func check_running() -> void:
	if Input.is_action_pressed("run"):
		player.duration = 0.15
	else:
		player.duration = 0.2
	
	player.speed = player.move_distance / player.duration

func handle_move(delta: float) -> void:
	if player.scripted_movement_active:
		return

	if not is_moving:
		var x = Input.get_axis("left", "right")
		var y = Input.get_axis("up", "down")
		input_dir = Vector2(x, y)

		# Start movement if input exists
		if input_dir != Vector2.ZERO:
			facing_dir = input_dir
			var motion = input_dir * player.move_distance
			if player.test_move(player.global_transform, motion):
				return
			is_moving = true
			prev_pos = player.global_position
			target_pos = player.global_position + input_dir * player.move_distance

	# ----- 2. MOVE TOWARD TARGET -----
	if is_moving:
		player.global_position = player.global_position.move_toward(target_pos, player.speed * delta)
		# If reached tile, stop or chain next tile if still holding input
		if player.global_position == target_pos:
			is_moving = false
			if transition_to_cutscene:
				change_state.emit(self, "cutscene")

func is_facing_towards(target: Node2D) -> bool:
	var target_dir: Vector2
	var dir = (target.global_position - player.global_position)
	if abs(dir.x) > abs(dir.y):
		target_dir = Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		target_dir = Vector2.DOWN if dir.y > 0 else Vector2.UP
	return target_dir == facing_dir

func interact() -> void:
	if not player.npcs_in_range.is_empty():
		for n in player.npcs_in_range:
			if is_facing_towards(n):
				player.facing_npc = n
				break
			else:
				player.facing_npc = null
		if player.facing_npc:
			change_state.emit(self, "talking")

func damage_pushback() -> void:
	# Temp
	print("ow")
	player.target_pos = player.prev_pos

#region Signals

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Npcs"):
		# Bc the Area2D is in the group
		var npc: Npc = area.get_parent()
		player.npcs_in_range.push_back(npc)
		npc.toggle_hint_visibility(true)
	if area.is_in_group("WorldDamage"):
		damage_pushback()
	if area.is_in_group("Cutscene"):
		if StoryManager.story_progress == area.required_cutscene:
			player.cutscene_area = area
			transition_to_cutscene = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Npcs"):
		var npc: Npc = player.npcs_in_range.pop_at(player.npcs_in_range.find(area.get_parent()))
		npc.toggle_hint_visibility(false)

#endregion
