extends PanelContainer
class_name SwapMenuSwapCharBox

var char_id: String
var style: StyleBoxFlat

func set_data(ch: CharacterData) -> void:
	char_id = ch.char_id
	%CharIcon.texture = ch.style.portrait
	%NameLabel.text = ch.style.char_name
	%StatLabel.text = "Lvl. " + str(ch.level)
	style = get_theme_stylebox("panel").duplicate()
	style.border_color = Color(ch.style.color, 0)
	add_theme_stylebox_override("panel", style)

func is_hovered(hovered: bool) -> void:
	style.border_color.a = 1 if hovered else 0
