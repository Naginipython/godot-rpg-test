extends Control
class_name Combat

@onready var menu = preload("res://scenes/obj/battle/player_menu.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var battle: AttackGame = $BattleContainer/Battle
@onready var cute_panel: PackedScene = preload("uid://c47gooh5kqn31")

var player_menus: Array[PlayerMenu]
var cute_panels: Array[PanelContainer]
var boss_hp: int = 100
var boss_max_hp: int = 100

# Global state vars
var turn: int = 0
var menu_idx: int = 0
var lines: Array[DialogueLine] = [] # to delete
var moves: Array = [] # Array[ Tuple [ Attack/Action/Item, char_id, _target ] ]
var player_stat_changes: Dictionary[String, Dictionary] = {}
# Choice vars
var choose_char_act: Action = null
var choose_char_itm: Item = null

func _ready() -> void:
	# TEMP
	GameManager.get_char_data("bibi").health = 0
	GameManager.sort_party()
	for character in GameManager.party:
		var menu_inst: PlayerMenu = menu.instantiate()
		menu_inst.init_menu(character)
		menu_inst.use_attack.connect(_on_use_attack)
		menu_inst.use_action.connect(_on_use_action)
		menu_inst.use_item.connect(_on_use_item)
		menu_inst.prev_turn.connect(prev_turn)
		%PlayerMenuContainer.add_child(menu_inst)
		player_menus.push_back(menu_inst)
		
		create_cute_panels.call_deferred(character.style.color, menu_inst)
		player_stat_changes[character.char_id] = {
			CharacterData.BuffableStats.STR: 0,
			CharacterData.BuffableStats.DEF: 0,
			CharacterData.BuffableStats.SPD: 0,
			CharacterData.BuffableStats.ACC: 0,
			CharacterData.BuffableStats.EVAD: 0
		}
	
	player_menus[0].selected = true
	turn = 0

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

func next_turn() -> void:
	player_menus[menu_idx].selected = false
	turn += 1
	turn %= 5
	var offset = 1
	while player_menus[turn].is_disabled:
		turn += 1
		offset += 1
		if turn == 4: break
	
	if turn != 4:
		player_menus[menu_idx+offset].prev_animation_playing = true
		menu_idx = turn
		player_menus[menu_idx].selected = true
		# Ensures menu isn't automatically in actions
		if player_menus[menu_idx-offset].animation_player.is_playing():
			await player_menus[menu_idx-offset].animation_player.animation_finished
		player_menus[menu_idx].prev_animation_playing = false
	else:
		#%StateMachine.curr_state.change_state.emit(self, "dialogue")
		#change_state.emit(self, "attackgame")
		menu_idx = 0

func prev_turn() -> void:
	if turn == 0: return
	player_menus[menu_idx].selected = false
	turn -= 1
	menu_idx = turn
	player_menus[menu_idx].selected = true
	moves.pop_back()

func apply_target(target_id: String) -> void:
	var data: Array = moves.back()
	data.push_back(target_id)

# it was pissing me off that I got errors using _on_use_attack
func _on_use_attack(attack: Attack) -> void:
	var data = [attack, player_menus[menu_idx].char_id]
	moves.push_back(data)
	next_turn()

func _on_use_action(action: Action) -> void:
	var data = [action, player_menus[menu_idx].char_id]
	moves.push_back(data)
	if action.type == Action.ActionType.Debuff:
		pass # TODO: Enemy select
	else:
		if action.is_target_all:
			next_turn()
		else:
			choose_char_act = action
			# next_turn after choice

func _on_use_item(item: Item) -> void:
	if item.type == Item.ItemType.Debuff:
		pass # TODO: Enemy select
	else:
		if item.is_target_all:
			next_turn()
		else:
			choose_char_itm = item
			# next_turn after choice
	var data = [item, player_menus[menu_idx].char_id]
	moves.push_back(data)
