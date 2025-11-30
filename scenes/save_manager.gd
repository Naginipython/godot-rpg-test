extends Node
class_name Save

const PATH: String = "user://save/"
var file_name: String = "save_data.json"
var key: String = "Phase Connect LOVE <3"

var data: Dictionary
var char_data: Array[CharacterData]
var world_data: Dictionary

func new_game() -> void:
	char_data = [
		load("uid://cad3qxc5u3kse"), # Nitya
		load("uid://b1mqycx2b2n65"), # Mina
		load("uid://c2w6a4dwau6hc"), # Malice
		load("uid://w8ogndpmr2ft") # Bibi
	]
	world_data = {
		"story_progress": Story.StoryPoint.SagaBegins,
		"player_pos": Vector2.ZERO
	}
	data = {
		"char_data": char_data,
		"world_data": world_data
	}
	send_to_game_manager()

func load_game() -> void:
	if FileAccess.file_exists(PATH + file_name):
		var file = FileAccess.open_encrypted_with_pass(PATH + file_name, FileAccess.READ, key)
		data = JSON.parse_string(file.get_as_text())
		file.close()

func save_game() -> void:
	# Get data from GameManager, save to respective areas
	var file = FileAccess.open_encrypted_with_pass(PATH + file_name, FileAccess.WRITE, key)
	file.store_string(JSON.stringify(data))
	file.close()

func is_saved_data() -> bool:
	return FileAccess.file_exists(PATH + file_name)

func send_to_game_manager() -> void:
	GameManager.player_pos = world_data['player_pos']
	GameManager.load_chars(char_data)
	StoryManager.story_progress = world_data['story_progress']
