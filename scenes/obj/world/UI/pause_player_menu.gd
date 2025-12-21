extends PanelContainer

@onready var hp_bar: ProgressBar = %HpBar
@onready var hp_label: Label = %HpLabel
var character_data: CharacterData = load("uid://cad3qxc5u3kse")

func _ready() -> void:
	set_menu(character_data)

func init_menu(ch: CharacterData) -> void:
	character_data = ch

func set_menu(ch: CharacterData) -> void:
	character_data = ch
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(ch.style.color)
	add_theme_stylebox_override("panel", stylebox)
	
	%Portrait.texture = ch.style.portrait
	%NameLabel.text = ch.style.char_name
	
	hp_bar.max_value = ch.curr_max_health
	hp_bar.value = ch.health
	hp_label.text = str(ch.health) + "/" + str(ch.curr_max_health)

func set_stats() -> void:
	set_stats_custom()

func set_stats_custom(items: String = "", stats: String = "") -> void:
	var held_label: RichTextLabel = %HeldLabel
	held_label.visible = true
	var stat_num_label: RichTextLabel = %StatNumLabel
	stat_num_label.visible = true
	
	if items == "":
		held_label.text = "WEAPON: " + "None" + "\n" +\
						  "CHARM: " + "None"
	elif items == null:
		held_label.visible = false
	else:
		held_label.text = items
	
	if stats == "":
		# TODO: weapon stats w/curr in ()
		stat_num_label.text = "STR: " + str(character_data.curr_str) + "\n" +\
							  "DEF: " + str(character_data.curr_def) + "\n" +\
							  "SPD: " + str(character_data.curr_spd) + "\n" +\
							  "ACC: " + str(character_data.curr_acc) + "\n" +\
							  "EVAD: " + str(character_data.curr_evad) + "\n"
	elif stats == null:
		stat_num_label.visible = false
	else:
		stat_num_label.text = stats
