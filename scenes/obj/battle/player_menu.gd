extends Control
class_name PlayerMenu

#@export var idx: int = 0
@export var selected: bool = false
var char_id: String = ""
var img: CompressedTexture2D = preload("uid://cbcfedh8onyr7")
var color: Color = Color8(255, 81, 112, 255)
var hp: int = 100
var max_hp: int = 100
var character: CharacterData = preload("uid://cad3qxc5u3kse")
var parent: Node
var prev_animation_playing: bool = false

@export var curr_state: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var char_icon: TextureRect = %CharIcon
@onready var stats_panel: PanelContainer = $StatsPanel
@onready var selected_container: CenterContainer = $SelectedContainer
@onready var hp_container: VBoxContainer = $StatsPanel/HBoxContainer/HpContainer

func _ready() -> void:
	char_icon.texture = img
	var stylebox := stats_panel.get_theme_stylebox("panel").duplicate()
	stylebox.set("bg_color", color)
	stats_panel.add_theme_stylebox_override("panel", stylebox)
	
	hp_container.get_child(0).text = str(hp) + "/" + str(max_hp)
	hp_container.get_child(1).max_value = max_hp
	hp_container.get_child(1).value = hp

func _process(_delta: float) -> void:
	$SelectedContainer.visible = selected
	curr_state = $StateMachine.curr_state.name.to_lower()

func init_menu(set_character: CharacterData, set_parent: Node) -> void:
	set_character.connect("initialized", double_check)
	character = set_character
	#idx = set_character.party_order
	img = set_character.style.portrait
	color = set_character.style.color
	#selected = set_character.party_order == 0
	char_id = set_character.char_id
	hp = set_character.health
	max_hp = set_character.curr_max_health
	set_character.health_changed.connect(change_hp)
	parent = set_parent

func double_check(set_character: CharacterData) -> void:
	hp = set_character.health
	max_hp = set_character.curr_max_health
	hp_container.get_child(0).text = str(hp) + "/" + str(max_hp)
	hp_container.get_child(1).max_value = max_hp
	hp_container.get_child(1).value = hp

func change_hp(new_value: int) -> void:
	var change = new_value-hp
	if change != 0:
		var damage: Label = preload("uid://b878c367s711p").instantiate()
		damage.text = str(change)
		add_child(damage)
		hp = new_value
		hp_container.get_child(0).text = str(hp) + "/" + str(max_hp)
		hp_container.get_child(1).value = hp

func use_attack(attack: String) -> void:
	print(attack)
	# Find attack details, apply buffs, etc
	parent.log_attack(character.style.char_name + " used " + attack + "!")
	parent.damage_boss(10)
