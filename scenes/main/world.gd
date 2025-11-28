extends Node

@export var text_ui: TextUI

var is_waiting_for_dialogue: bool = false
var is_animation_finished: bool = false

func _ready() -> void:
	# Place player
	$Player.global_position = GameManager.tilepos_to_worldpos(GameManager.player_pos)

# Cutscene Manager (for now?)

func pause_for_dialogue(convo: Conversation) -> void:
	$CutScenePlayer.pause()
	text_ui.enable_text(convo)
	is_waiting_for_dialogue = true

func animation_started() -> void:
	$UI/WackyTextTest.text += str(GameManager.characters.keys())
	is_animation_finished = false

func _on_text_ui_convo_finished() -> void:
	if is_waiting_for_dialogue:
		is_waiting_for_dialogue = false
		if not is_animation_finished:
			$CutScenePlayer.play()

func _on_cut_scene_player_animation_finished(_anim_name: StringName) -> void:
	is_animation_finished = true
