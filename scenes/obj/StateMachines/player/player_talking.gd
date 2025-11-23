extends PlayerState

func enter(_prev: String) -> void:
	# Extract NPC data
	player.text_ui.enable_text(player.facing_npc)

func process(_delta: float) -> void:
	if not player.text_ui.is_enabled:
		change_state.emit(self, "main")
	if Input.is_action_just_pressed("select"):
		player.text_ui.next_text()
	#if Input.is_action_just_pressed("select") and player.text_ui.is_talking:
		#player.text_ui.impatient()
		#print("interrupt")

func exit(_next: String) -> void:
	pass
