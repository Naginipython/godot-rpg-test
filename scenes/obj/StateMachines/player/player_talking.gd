extends PlayerState

func enter(_prev: String) -> void:
	# Extract NPC data
	var point: StoryManager.StoryPoint = StoryManager.dialogue_check(player.facing_npc.dialogue.keys())
	player.text_ui.enable_text(player.facing_npc.dialogue[point])

func process(_delta: float) -> void:
	if not player.text_ui.is_enabled:
		change_state.emit(self, "main")
