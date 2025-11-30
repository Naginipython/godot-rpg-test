extends Control

@onready var load_btn: Button = $CenterContainer/PanelContainer/VBoxContainer/LoadBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveManager.is_saved_data():
		load_btn.visible = true
	else:
		load_btn.visible = false

func _on_new_game_btn_pressed() -> void:
	SaveManager.new_game()
	GameManager.change_mode(Game.Modes.WORLD)

func _on_load_btn_pressed() -> void:
	pass # Replace with function body.
