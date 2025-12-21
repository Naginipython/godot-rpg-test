extends PlayerState

var unconnected: bool = true

func enter(_prev: String) -> void:
	# Extract NPC data
	var point: StoryManager.StoryPoint = StoryManager.dialogue_check(player.facing_npc.dialogue.keys())
	if unconnected:
		player.text_ui.connect("convo_finished", _on_convo_finished)
		player.text_ui.connect("option_chosen", _on_option_chosen)
		unconnected = false
	if player.facing_npc is Lecturn:
		for p in GameManager.party:
			p.health = p.curr_max_health
		player.text_ui.enable_text_w_options(player.facing_npc.dialogue[point], player.facing_npc.options.keys())
	else:
		player.text_ui.enable_text(player.facing_npc.dialogue[point])

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		get_viewport().set_input_as_handled()
		player.text_ui.pressed_select()
	if event.is_action_pressed("up"):
		player.text_ui.option_select("up")
	elif event.is_action_pressed("down"):
		player.text_ui.option_select("down")

func _on_convo_finished() -> void:
	player.text_ui.disable_text()
	change_state.emit(self, "main")

func _on_option_chosen(option: String) -> void:
	var next = player.facing_npc.apply_option(option)
	if next:
		player.text_ui.next_text(next)
	else:
		player.text_ui.disable_text()
		change_state.emit(self, "main")
