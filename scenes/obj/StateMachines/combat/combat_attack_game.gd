extends CombatState

@onready var battle: AttackGame = $"../../BattleContainer/Battle"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var players_attacked: Array[int]

func enter(_prev: String) -> void:
	battle.start()
	animation_player.play("start_attack_game")
	get_three_random_players()
	await animation_player.animation_finished
	cute_panel_animate_start()

func exit(_next: String) -> void:
	animation_player.play("end_attack_game")
	cute_panel_animate_end()

func get_three_random_players() -> void:
	players_attacked = []
	while players_attacked.size() < 3:
		var n = randi_range(0, 3)
		if players_attacked.find(n) == -1:
			players_attacked.push_back(n)
	players_attacked.sort()
		
	for i in range(0, players_attacked.size()):
		battle.set_panel_to_char(i, players_attacked[i], GameManager.party[players_attacked[i]].style.color)

func end_game() -> void:
	change_state.emit(self, "main")

func cute_panel_animate_start() -> void:
	for i in range(0, 3):
		combat.cute_panels[players_attacked[i]].visible = true
		var panel: Panel
		match i:
			0: panel = battle.panel_q
			1: panel = battle.panel_w
			2: panel = battle.panel_e
		var tween = create_tween()
		var center: Vector2 = Vector2(
			panel.global_position.x + panel.size.x/2 - combat.cute_panels[players_attacked[i]].size.x/2, 
			panel.global_position.y)
		tween.tween_property(combat.cute_panels[players_attacked[i]], "position", center, 0.1)
		tween.chain() # Waits for above first
		tween.tween_property(combat.cute_panels[players_attacked[i]], "size", panel.size, 0.1)
		tween.tween_property(combat.cute_panels[players_attacked[i]], "position", panel.global_position, 0.1)
		combat.cute_panels[players_attacked[i]].enable()

func cute_panel_animate_end() -> void:
	var player_menus = combat.player_menus
	var cute_panels = combat.cute_panels
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
