extends PlayerState

func enter(_prev: String) -> void:
	if not player.cutscene_player:
		change_state.emit(self, "main")
	
	# TODO: tween to cutscene_area's marker 2d, duration based on tiles * 0.2
	# TODO: Check for non-sequential, keep a list of cutscene_area that have been trigger
	# when not sequential (story progress vs simple thingy idk)
	var diff: Vector2 = player.global_position - player.cutscene_area.marker.global_position
	var duration: float = 0
	var x_dur: float = abs(diff.x/16) * 0.2
	var y_dur: float = abs(diff.y/16) * 0.2
	if y_dur: duration = y_dur
	elif x_dur: duration = x_dur
	var tween: Tween = create_tween()
	tween.tween_property(player, "global_position", player.cutscene_area.marker.global_position, duration)
	await tween.finished
	
	if player.cutscene_area.cutscene_id-1 == StoryManager.story_progress:
		if player.cutscene_player.has_animation(player.cutscene_area.name):
			StoryManager.story_progress += 1
			player.cutscene_player.play(player.cutscene_area.name)
	else:
		change_state.emit(self, "main")

func process(_delta: float) -> void:
	if player.world.is_animation_finished:
		change_state.emit(self, "main")
