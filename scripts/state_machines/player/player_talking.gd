extends PlayerState

func enter(_prev: String) -> void:
	var dialogue: Resource = player.facing_npc.dialogue
	var dialogue_start: String = player.facing_npc.dialogue_start
	var balloon = DialogueManager.show_dialogue_balloon(dialogue, dialogue_start)
	balloon.connect("ended", _on_dialogue_ended, CONNECT_ONE_SHOT)
	pass

#region Signals

func _on_dialogue_ended() -> void:
	change_state.emit(self, "main")

#endregion
