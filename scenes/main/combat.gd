extends Control
class_name Combat

@onready var menu = preload("res://scenes/obj/battle/player_menu.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var battle: AttackGame = $BattleContainer/Battle
@onready var cute_panel: PackedScene = preload("uid://c47gooh5kqn31")

var player_menus: Array[PlayerMenu]
var cute_panels: Array[PanelContainer]
var on_attack_game: bool = false
var menu_idx: int = 0
var turn: int = 0
var boss_hp: int = 100
var boss_max_hp: int = 100

var lines: Array[DialogueLine] = []

func _ready() -> void:
	GameManager.sort_party()
	for character in GameManager.party:
		var menu_inst: PlayerMenu = menu.instantiate()
		menu_inst.init_menu(character, $StateMachine/Main)
		%PlayerMenuContainer.add_child(menu_inst)
		player_menus.push_back(menu_inst)
		
		create_cute_panels.call_deferred(character.style.color, menu_inst)

func _process(_delta: float) -> void:
	if not player_menus.is_empty():
		
		if Input.is_action_just_pressed("temp_battle_end"):
			StoryManager.enable_flag(StoryManager.StoryPoint.fBossDefeated)
			GameManager.change_mode(GameManager.Modes.WORLD)
		if Input.is_action_just_pressed("temp_enemy_attack"):
			pass
		# Menu change test
		#if Input.is_action_just_pressed("up"):
			#var child3: PlayerMenu = %PlayerMenuContainer.get_child(2)
			#%PlayerMenuContainer.move_child(child3, 1)

func create_cute_panels(color: Color, playerMenu: PlayerMenu) -> void:
	var panel_inst: PanelContainer = cute_panel.instantiate()
	panel_inst.set_color(color)
	panel_inst.global_position.x = playerMenu.global_position.x + playerMenu.size.x/2
	panel_inst.global_position.y = playerMenu.global_position.y + playerMenu.size.y/2
	panel_inst.z_index = -1
	cute_panels.push_back(panel_inst)
	add_child(panel_inst)
