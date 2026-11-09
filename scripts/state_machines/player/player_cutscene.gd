extends PlayerState

func enter(_prev: String) -> void:
	if player.cutscene_area:
		if player.cutscene_area.required_cutscene == StoryManager.story_progress:
			var diff: Vector2 = player.global_position - player.cutscene_area.start_marker.global_position
			var duration: float = 0
			var x_dur: float = abs(diff.x/16) * 0.2
			var y_dur: float = abs(diff.y/16) * 0.2
			if y_dur: duration = y_dur
			elif x_dur: duration = x_dur
			var tween: Tween = create_tween()
			tween.tween_property(player, "global_position", player.cutscene_area.start_marker.global_position, duration)
			await tween.finished
			
			var balloon = DialogueManager.show_dialogue_balloon(player.cutscene_area.dialogue, player.cutscene_area.cue)
			
			balloon.connect("ended", _on_dialogue_ended, CONNECT_ONE_SHOT)
		else:
			change_state.emit(self, "main")

func _on_dialogue_ended() -> void:
	player.end_talking()
	change_state.emit(self, "main")
