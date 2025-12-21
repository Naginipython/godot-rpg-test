extends PanelContainer
class_name SwapMenuCharBox

var char_id: String

func set_data(ch: CharacterData) -> void:
	char_id = ch.char_id
	%CharIcon.texture = ch.style.portrait
	%NameLabel.text = ch.style.char_name
	%StatLabel.text = "Lvl. " + str(ch.level)
	var style: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	style.bg_color = ch.style.color
	add_theme_stylebox_override("panel", style)
	
