extends Node

@onready var game: Node = $"."

func _ready() -> void:
	# Place player
	$Player.global_position = Game_singleton.tilepos_to_worldpos(Game_singleton.player_pos)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	print("Respawn Test")
