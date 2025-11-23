# JSONImporter.gd
@tool
extends EditorScript

func _run():
	# 1. Load the JSON file
	var file = FileAccess.open("res://data/characters.json", FileAccess.READ)
	var json_text = file.get_as_text()
	
	# 2. Parse it
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
		
	var data_array = json.data
	
	# 3. Loop through data and create Resources
	for entry in data_array:
		var new_res = CharacterData.new()
		
		# Map JSON fields to Resource variables
		new_res.character_id = entry["id"]
		new_res.display_name = entry["name"]
		new_res.max_hp = int(entry["hp"])
		new_res.dialogue_lines = []
		
		# Handle arrays manually to ensure type safety
		for line in entry["lines"]:
			new_res.dialogue_lines.append(line)
		
		# 4. Save to .tres
		# Ensure the folder exists first!
		var save_path = "res://resources/characters/" + entry["id"] + ".tres"
		ResourceSaver.save(new_res, save_path)
		print("Saved: " + save_path)
	
	# Refresh the FileSystem so they appear instantly
	EditorInterface.get_resource_filesystem().scan()
