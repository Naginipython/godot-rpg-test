extends PlayerMenuState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var btn_idx: int = 0

func enter(prev: String) -> void:
	if prev.to_lower() == "main":
		animation_player.play("CardSwapToActions")
		%AttackBtn.grab_focus()

func process(_delta: float) -> void:
	action_selection()
	if Input.is_action_just_pressed("select") and not animation_player.is_playing():
		push_btn(btn_idx)

func exit(next: String) -> void:
	btn_idx = 0
	if next.to_lower() == "main":
		animation_player.play("CardSwapToMain")

func action_selection():
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		# 0 -> 1. 1 -> 0
		# 2 -> 3. 3 -> 2
		if btn_idx % 2 == 0:
			btn_idx += 1
		else:
			btn_idx -= 1
	elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down"):
		# 0 -> 2. 2 -> 0
		# 1 -> 3. 3 -> 1
		if btn_idx - 2 < 0:
			btn_idx += 2
		else:
			btn_idx -= 2
	select_btn(btn_idx)

func select_btn(idx: int) -> void:
	match idx:
		0: %AttackBtn.grab_focus()
		1: %ActionBtn.grab_focus()
		2: %CollabBtn.grab_focus()
		3: %ItemBtn.grab_focus()

func push_btn(idx: int) -> void:
	match idx:
		0: %AttackBtn.emit_signal("pressed")
		1: %ActionBtn.emit_signal("pressed")
		2: %CollabBtn.emit_signal("pressed")
		3: %ItemBtn.emit_signal("pressed")

func _on_attack_btn_pressed() -> void:
	change_state.emit(self, "action_attack")
