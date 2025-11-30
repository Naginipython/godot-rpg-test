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
	send_to_managers()

func load_game() -> void:
	if FileAccess.file_exists(PATH + file_name):
		var file = FileAccess.open_encrypted_with_pass(PATH + file_name, FileAccess.READ, key)
		data = JSON.parse_string(file.get_as_text())
		file.close()
		print(data)
		
		char_data = data['char_data']
		world_data = data['world_data']
		send_to_managers()
		print(char_data)

func save_game() -> void:
	# Get data from GameManager, save to respective areas
	char_data = GameManager.characters.values()
	print(char_data)
	world_data = {
		"story_progress": StoryManager.story_progress,
		"player_pos": GameManager.player_pos
	}
	data = {
		"char_data": char_data,
		"world_data": world_data
	}
	if not DirAccess.dir_exists_absolute(PATH):
		DirAccess.make_dir_recursive_absolute(PATH)
		
	var file = FileAccess.open_encrypted_with_pass(PATH + file_name, FileAccess.WRITE, key)
	if not file:
		print("Error saving: ", FileAccess.get_open_error())
		return
	
	file.store_string(JSON.stringify(data))
	file.close()
	var real_path = ProjectSettings.globalize_path(PATH)
	print("My absolute path is: ", real_path)

func is_saved_data() -> bool:
	return FileAccess.file_exists(PATH + file_name)

func send_to_managers() -> void:
	GameManager.load_chars(char_data)
	GameManager.player_pos = world_data['player_pos']
	StoryManager.story_progress = world_data['story_progress']
