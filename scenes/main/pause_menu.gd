extends PanelContainer

@export var player: Player
@export var world: Node

func _on_save_btn_temp_pressed() -> void:
	if player:
		GameManager.player_pos = GameManager.worldpos_to_tilepos(player.global_position)
	SaveManager.save_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		world.toggle_paused()
		get_viewport().set_input_as_handled()
