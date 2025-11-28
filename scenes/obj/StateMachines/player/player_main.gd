extends PlayerState

@onready var upper_tile_layer: TileMapLayer = $"../../../UpperTileLayer"
@onready var interact_cooldown: Timer = $"../../InteractCooldown"

const MOVE_DISTANCE: float = 16.0
var duration: float = 0.2
var speed: float = MOVE_DISTANCE / duration
	
var is_moving: bool = false
var target_pos: Vector2
var prev_pos: Vector2
var facing_dir: Vector2 = Vector2.DOWN

var is_in_cutscene: bool = false

func enter(prev: String) -> void:
	target_pos = player.global_position
	is_in_cutscene = false
	if prev == "talking":
		interact_cooldown.start()

func physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("select") and interact_cooldown.is_stopped():
		interact()
	check_running()
	handle_move(delta)

func check_running() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		duration = 0.15
	else:
		duration = 0.2
	
	speed = MOVE_DISTANCE / duration

func handle_move(delta: float) -> void:
	if not is_moving:
		var x = Input.get_axis("left", "right")
		var y = Input.get_axis("up", "down")
		var input_dir = Vector2(x, y)

		# Start movement if input exists
		if input_dir != Vector2.ZERO:
			facing_dir = input_dir
			var motion = input_dir * MOVE_DISTANCE
			if player.test_move(player.global_transform, motion): return
			is_moving = true
			prev_pos = player.global_position
			target_pos = player.global_position + input_dir * MOVE_DISTANCE

	# ----- 2. MOVE TOWARD TARGET -----
	if is_moving:
		player.global_position = player.global_position.move_toward(target_pos, speed * delta)
		# If reached tile, stop or chain next tile if still holding input
		if player.global_position == target_pos:
			is_moving = false
			if is_in_cutscene:
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
	target_pos = prev_pos

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Enemies"):
		GameManager.enemies_dead_pos.push_back(area.get_parent().spawnpoint.global_position)
		GameManager.record_pos(GameManager.worldpos_to_tilepos(target_pos))
		GameManager.change_mode(GameManager.Modes.COMBAT)
	if area.get_parent().is_in_group("Npcs"):
		area.get_parent().toggle_hint_visibility(true)
		player.npcs_in_range.push_back(area.get_parent())
	if area.is_in_group("WorldDamage"):
		damage_pushback()
	if area.is_in_group("CutScene"):
		player.cutscene_area = area
		is_in_cutscene = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Npcs"):
		var npc: Npc = player.npcs_in_range.pop_at(player.npcs_in_range.find(area.get_parent()))
		npc.toggle_hint_visibility(false)
