extends PlayerState

func enter(_prev: String) -> void:
	# Extract NPC data
	if player.facing_npc.name.begins_with("Debug"):
		player.text_ui.temp_disable_face_size()
	var point: StoryManager.StoryPoint = StoryManager.dialogue_check(player.facing_npc.dialogue.keys())
	player.text_ui.enable_text(player.facing_npc.dialogue[point])

#func unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("select"):
		#if player.text_ui.is_printing and player.text_ui.can_skip: 
			#player.text_ui.impatient()
		#else: 
			#player.text_ui.next_text()

func process(_delta: float) -> void:
	if not player.text_ui.is_enabled:
		change_state.emit(self, "main")

func exit(_next: String) -> void:
	pass
