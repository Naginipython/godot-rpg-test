class_name Game
extends Node

@export var temp_character_data: Array[CharacterData]

enum Modes {
	MAIN_MENU, WORLD, COMBAT
}

var mode: Modes = Modes.WORLD
var player_pos: Vector2 = Vector2.ZERO # conver to Dict
var characters: Dictionary[String, CharacterData] = {}
var party: Array[CharacterData] = []
# Item_name: { desc, type, idk }
var items: Array[Item] = []

var enemies_dead_pos: Array[Vector2]

func load_chars(character_data: Array[CharacterData]) -> void:
	for character in character_data:
		if character.char_id:
			characters[character.char_id] = character
			print("Loaded char: " + character.char_id)
	
	# Get Party, sorted
	for character: CharacterData in characters.values():
		if character.active:
			party.push_back(character)

# ----- Get Char Data -----
func get_char_data(id: String) -> CharacterData:
	if characters.has(id):
		return characters[id]
	push_error("Error: Char ID %s not found", id)
	return null
func get_attacks(id: String) -> Dictionary[String, Attack]:
	if characters.has(id):
		return characters[id].attacks.duplicate()
	return {}
func get_actions(id: String) -> Dictionary[String, Action]:
	if characters.has(id):
		return characters[id].actions.duplicate()
	return {}
func get_items() -> Array[Item]:
	return items.duplicate()
func sort_party() -> void:
	party.sort_custom(func(a: CharacterData, b: CharacterData):
		return a.curr_spd > b.curr_spd)

# ----- Change Char Data [Will say if hard save] -----
# Save Character (hp, attacks, level, party order, etc) [To tres, hard save]
# Change party order
# Change party active
# Change party hp

# ----- Location Assistance -----
func worldpos_to_tilepos(worldpos: Vector2) -> Vector2:
	# (8,8) is (0,0). (24, 24) is (24-8/16, 24-8/16)
	return Vector2((worldpos.x-8)/16, (worldpos.y-8)/16)
func tilepos_to_worldpos(tilepos: Vector2) -> Vector2:
	# (0,0) is (8,8). (1,1) is (8+16, 8+16)
	return Vector2(8+tilepos.x*16, 8+tilepos.y*16)

func record_pos(pos: Vector2) -> void:
	player_pos = pos

func change_mode(new_mode: Modes) -> void:
	match new_mode:
		Modes.WORLD:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/main/world.tscn")
		Modes.COMBAT:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/main/combat.tscn")
