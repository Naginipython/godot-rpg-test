class_name GameManager
extends Node

@export var temp_character_data: Array[CharacterData]

enum Modes {
	MAIN_MENU, WORLD, COMBAT
}

var mode: Modes = Modes.WORLD
var characters: Dictionary[String, CharacterData] = {}
var party: Array[CharacterData] = []
var items: Array[Item] = []

func _ready() -> void:
	if characters.is_empty():
		load_chars(temp_character_data)

func load_chars(character_data: Array[CharacterData]) -> void:
	for character in character_data:
		if character.char_id:
			characters[character.char_id] = character
			print("Loaded char: " + character.char_id)
	
	# Get Party, sorted
	for character: CharacterData in characters.values():
		if character.active:
			party.push_back(character)
