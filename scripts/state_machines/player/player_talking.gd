extends PlayerState

func enter(_prev: String) -> void:
	if player.facing_npc:
		var dialogue: Resource = player.facing_npc.dialogue
		var dialogue_start: String = player.facing_npc.dialogue_start
		var balloon = DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
		balloon.connect("ended", _on_dialogue_ended, CONNECT_ONE_SHOT)
	elif player.dialogue:
		var balloon = DialogueManager.show_dialogue_balloon(player.dialogue, player.cue)
		balloon.connect("ended", _on_dialogue_ended, CONNECT_ONE_SHOT)

#region Signalsadsdwa

func _on_dialogue_ended() -> void:
	player.end_talking()
	change_state.emit(self, "main")

#endregion
