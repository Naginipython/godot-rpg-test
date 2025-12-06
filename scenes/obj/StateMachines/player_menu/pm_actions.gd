extends PlayerMenuState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var btn_idx: int = 0

func enter(prev: String) -> void:
	if prev.to_lower() == "main":
		btn_idx = 0
		animation_player.play("CardSwapToActions")
		%MainGrid.get_child(btn_idx).grab_focus()

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return") and menu.selected and not animation_player.is_playing():
		change_state.emit(self, "main")
	
	if event.is_action_pressed("select") and not animation_player.is_playing():
		push_btn(btn_idx)

func process(_delta: float) -> void:
	action_selection()
	
	#if menu.selected and Input.is_action_just_pressed("return") and not animation_player.is_playing():
	

func exit(next: String) -> void:
	if next.to_lower() == "main":
		btn_idx = 0
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

func _on_action_btn_pressed() -> void:
	change_state.emit(self, "action_action")

func _on_collab_btn_pressed() -> void:
	pass # Replace with function body.

func _on_item_btn_pressed() -> void:
	change_state.emit(self, "action_item")
