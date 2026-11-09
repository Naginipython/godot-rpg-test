extends PlayerState

const MOVE_DISTANCE: float = 16.0
var duration: float = 0.2
var speed: float = MOVE_DISTANCE / duration
	
var is_moving: bool = false
var target_pos: Vector2
var prev_pos: Vector2
var facing_dir: Vector2 = Vector2.DOWN
#temp
var input_dir: Vector2

func enter(prev: String) -> void:
	target_pos = player.global_position

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"): # and interact_cooldown.is_stopped():
		#interact()
		pass

func process(_delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
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
		input_dir = Vector2(x, y)

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
