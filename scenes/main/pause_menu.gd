extends Control
class_name PauseMenu

const PAUSE_PLAYER_MENU = preload("uid://bkl3k4tk33tl4")

@export var player: Player
@export var world: Node

var party: Array[CharacterData]
var char_selected: int = -1

func _ready() -> void:
	%TempPausePlayerMenu.queue_free()
	$StatMenuTemplate.visible = false
	setup_box.call_deferred()

func setup_box() -> void:
	#GameManager.sort_party()
	party = GameManager.party
	for ch in party:
		var menu_inst: PanelContainer = PAUSE_PLAYER_MENU.instantiate()
		menu_inst.init_menu(ch)
		menu_inst.size = Vector2(255, 150)
		%PlayerMenuHBox.add_child(menu_inst)
	visible = false
