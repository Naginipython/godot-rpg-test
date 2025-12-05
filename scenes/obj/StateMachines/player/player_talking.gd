extends PlayerState

var unconnected: bool = true

func enter(_prev: String) -> void:
	# Extract NPC data
	var point: StoryManager.StoryPoint = StoryManager.dialogue_check(player.facing_npc.dialogue.keys())
	if unconnected:
		player.text_ui.connect("convo_finished", _on_convo_finished)
		unconnected = false
	player.text_ui.enable_text(player.facing_npc.dialogue[point])

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		player.text_ui.pressed_select()

#func process(_delta: float) -> void:
	#if not player.text_ui.is_enabled:
		#change_state.emit(self, "main")

func _on_convo_finished() -> void:
	player.text_ui.disable_text()
	change_state.emit(self, "main")
