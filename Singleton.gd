class_name Game
extends Node

enum Modes {
	WORLD, COMBAT
}

var mode: Modes = Modes.WORLD
var player_pos: Vector2 = Vector2.ZERO
var characters: Dictionary[String, CharacterData] = {}
var party: Array[CharacterData] = []
var items: Dictionary[String, Dictionary] = {}

var enemies_dead_pos: Array[Vector2]

func _ready() -> void:
	var char_data_files: PackedStringArray = DirAccess.get_files_at("res://assets/char_data/")
	for file_name in char_data_files:
		if file_name.ends_with(".tres"):
			var file = "res://assets/char_data/" + file_name
			var loaded_data: Resource = load(file)
			if loaded_data is CharacterData and not loaded_data.char_id.is_empty():
				var char_data: CharacterData = loaded_data
				characters[char_data.char_id] = char_data
				print("Loaded char: " + char_data.char_id)
	
	# Get Party, sorted
	for character: CharacterData in characters.values():
		if character.active:
			party.push_back(character.duplicate())

# ----- Get Char Data -----
func get_char_data(id: String) -> CharacterData:
	if characters.has(id):
		return characters[id].duplicate()
	push_error("Error: Char ID %s not found", id)
	return null
func get_attacks(id: String) -> PackedStringArray:
	if characters.has(id):
		return characters[id].attacks.duplicate()
	return []
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
