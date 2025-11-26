extends Control

@onready var menu = preload("res://scenes/obj/battle/player_menu.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var battle: AttackGame = $BattleContainer/Battle
@onready var cute_panel: PackedScene = preload("uid://c47gooh5kqn31")

var player_menus: Array[PlayerMenu]
var cute_panels: Array[PanelContainer]
var players_attacked: Array[int]
var menu_idx: int = 0
var on_attack_game: bool = false
var turn: int = 0
var boss_hp: int = 100

func _ready() -> void:
	Game_singleton.sort_party()
	print(Game_singleton.party)
	for character in Game_singleton.party:
		var menu_inst: PlayerMenu = menu.instantiate()
		menu_inst.init_menu(character, self)
		%PlayerMenuContainer.add_child(menu_inst)
		player_menus.push_back(menu_inst)
		
		create_cute_panels.call_deferred(character.style.color, menu_inst)
	player_menus[0].selected = true

func create_cute_panels(color: Color, playerMenu: PlayerMenu) -> void:
	var panel_inst: PanelContainer = cute_panel.instantiate()
	panel_inst.set_color(color)
	panel_inst.global_position.x = playerMenu.global_position.x + playerMenu.size.x/2
	panel_inst.global_position.y = playerMenu.global_position.y + playerMenu.size.y/2
	panel_inst.z_index = -1
	cute_panels.push_back(panel_inst)
	add_child(panel_inst)

func _process(_delta: float) -> void:
	if not player_menus.is_empty():
		# Choose Menu
		#if not on_attack_game:
			#menu_selection()
		if on_attack_game:
			if battle.is_game_end:
				animation_player.play("end_attack_game")
		# Select Menu
		if not on_attack_game:
			if Input.is_action_just_pressed("select") and player_menus[menu_idx].curr_state == "main":
				player_menus[menu_idx].swap("actions")
			if Input.is_action_just_pressed("return") and player_menus[menu_idx].curr_state == "actions":
				player_menus[menu_idx].swap("main")
		
		if Input.is_action_just_pressed("temp_battle_end"):
			StoryManager.story_progress += 1;
			StoryManager.enable_flag(StoryManager.StoryPoint.fBoss_Defeated)
			Game_singleton.change_mode(Game_singleton.Modes.WORLD)
		# Menu change test
		#if Input.is_action_just_pressed("up"):
			#var child3: PlayerMenu = %PlayerMenuContainer.get_child(2)
			#%PlayerMenuContainer.move_child(child3, 1)
 
func menu_selection():
	if player_menus[menu_idx].curr_state == "main":
		if Input.is_action_just_pressed("left"):
			if menu_idx == 0:
				menu_idx = player_menus.size()-1
			else:
				menu_idx -= 1
		elif Input.is_action_just_pressed("right"):
			if player_menus[menu_idx].curr_state != "main":
				player_menus[menu_idx].swap(player_menus[menu_idx].MenuModes.Stats)
			if menu_idx == player_menus.size()-1:
				menu_idx = 0
			else:
				menu_idx += 1
		# Updating index
		for i in range(player_menus.size()):
			if i == menu_idx:
				player_menus[i].selected = true
			else:
				player_menus[i].selected = false

func toggle_attack_game(mode: bool) -> void:
	on_attack_game = mode
	if mode:
		# Get 3 random numbers
		players_attacked = []
		while players_attacked.size() < 3:
			var n = randi_range(0, 3)
			if players_attacked.find(n) == -1:
				players_attacked.push_back(n)
		players_attacked.sort()
		
		for i in range(0, players_attacked.size()):
			battle.set_panel_to_char(i, players_attacked[i], Game_singleton.party[players_attacked[i]].style.color)
		battle.start()

func next_turn() -> void:
	player_menus[menu_idx].selected = false
	turn += 1
	turn %= 5
	if turn != 4:
		menu_idx = turn
		player_menus[menu_idx].selected = true
	else:
		animation_player.play("start_attack_game")
		menu_idx = 0

func damage_boss(dmg: int) -> void:
	boss_hp -= dmg
	next_turn()

func width_animate_start() -> void:
	for i in range(0, 3):
		cute_panels[players_attacked[i]].visible = true
		var panel: Panel
		match i:
			0: panel = battle.panel_q
			1: panel = battle.panel_w
			2: panel = battle.panel_e
		var tween = create_tween()
		var center: Vector2 = Vector2(
			panel.global_position.x + panel.size.x/2 - cute_panels[players_attacked[i]].size.x/2, 
			panel.global_position.y)
		tween.tween_property(cute_panels[players_attacked[i]], "position", center, 0.1)
		tween.chain() # Waits for above first
		tween.tween_property(cute_panels[players_attacked[i]], "size", panel.size, 0.1)
		tween.tween_property(cute_panels[players_attacked[i]], "position", panel.global_position, 0.1)
		cute_panels[players_attacked[i]].enable()

func width_animate_end() -> void:
	for i in range(0, 3):
		var center: Vector2 = Vector2(
			player_menus[players_attacked[i]].global_position.x + player_menus[players_attacked[i]].size.x/2 - cute_panels[players_attacked[i]].size.x/2, 
			player_menus[players_attacked[i]].global_position.y)
		var tween = create_tween()
		tween.tween_property(cute_panels[players_attacked[i]], "size", Vector2(50,50), 0.1)
		cute_panels[i].enable()
		tween.tween_property(cute_panels[players_attacked[i]], "position", center, 0.1)
		tween.chain()
		tween.tween_property(cute_panels[players_attacked[i]], "visible", false, 0.1)
