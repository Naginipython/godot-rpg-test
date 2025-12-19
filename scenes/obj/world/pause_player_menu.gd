extends PanelContainer

@onready var hp_bar: ProgressBar = %HpBar
@onready var hp_label: Label = %HpLabel
var character_data: CharacterData = load("uid://cad3qxc5u3kse")

func _ready() -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(character_data.style.color)
	add_theme_stylebox_override("panel", stylebox)
	
	%Portrait.texture = character_data.style.portrait
	%NameLabel.text = character_data.style.char_name
	
	hp_bar.max_value = character_data.curr_max_health
	hp_bar.value = character_data.health
	hp_label.text = str(character_data.health) + "/" + str(character_data.curr_max_health)

func init_menu(ch: CharacterData) -> void:
	character_data = ch
