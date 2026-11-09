class_name GameManager
extends Node

@export var temp_character_data: Array[CharacterData]

enum Modes {
	MAIN_MENU, WORLD, COMBAT
}

var mode: Modes = Modes.WORLD
var player: Player
var characters: Dictionary[String, CharacterData] = {}
var party: Array[CharacterData] = []
var items: Array[Item] = []

func _ready() -> void:
	if characters.is_empty():
		load_chars(temp_character_data)
	
	await get_tree().process_frame
	
	#player.start_talking(load("uid://ojry86wl3yv3"), "game_start")
	#DialogueManager.show_dialogue_balloon(load("uid://ojry86wl3yv3"), "game_start")

func register_player(new_player: Player) -> void:
	player = new_player

func unregister_player(leaving_player: Player) -> void:
	if player == leaving_player:
		player = null

func load_chars(character_data: Array[CharacterData]) -> void:
	for character in character_data:
		if character.char_id:
			characters[character.char_id] = character
			print("Loaded char: " + character.char_id)
	
	# Get Party, sorted
	for character: CharacterData in characters.values():
		if character.active:
			party.push_back(character)

# ----- Location Assistance -----
func worldpos_to_tilepos(worldpos: Vector2) -> Vector2:
	# (8,8) is (0,0). (24, 24) is (24-8/16, 24-8/16)
	return Vector2((worldpos.x-8)/16, (worldpos.y-8)/16)
func tilepos_to_worldpos(tilepos: Vector2) -> Vector2:
	# (0,0) is (8,8). (1,1) is (8+16, 8+16)
	return Vector2(8+tilepos.x*16, 8+tilepos.y*16)

func change_mode(new_mode: Modes) -> void:
	match new_mode:
		Modes.WORLD:
			#get_tree().call_deferred("change_scene_to_file", "res://scenes/main/world.tscn")
			pass
		Modes.COMBAT:
			#get_tree().call_deferred("change_scene_to_file", "res://scenes/main/combat.tscn")
			pass
