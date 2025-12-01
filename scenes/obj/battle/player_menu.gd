extends Control
class_name PlayerMenu

#@export var idx: int = 0
@export var selected: bool = false
var parent: Node
var prev_animation_playing: bool = false
var is_disabled = false
# Style
var character: CharacterData = preload("uid://cad3qxc5u3kse")
var char_id: String = ""
var img: CompressedTexture2D = preload("uid://cbcfedh8onyr7")
var color: Color = Color8(255, 81, 112, 255)
var hp: int = 100
var max_hp: int = 100
var attacks: Dictionary[String, Attack] = {}
var actions: Dictionary[String, Action] = {}
var items: Array[Item] = []

# nodes
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
	
	attacks = GameManager.get_attacks(char_id)
	actions = GameManager.get_actions(char_id)
	items = GameManager.get_items()
	setup_btns(attacks.keys(), %AtkBtnsContainer)
	setup_btns(actions.keys(), %ActBtnsContainer)

func _process(_delta: float) -> void:
	$SelectedContainer.visible = selected

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

func setup_btns(category: Array[String], container: VBoxContainer) -> void:
	# Add buttons
	if category.is_empty(): return
	var button = container.get_child(0)
	button.text = category[0]
	for i in range(1, category.size()):
		var dup = button.duplicate()
		dup.text = category[i]
		container.add_child(dup)

# ----- THE GOOD STUFF -----

func disable() -> void:
	is_disabled = true
	modulate = Color.from_hsv(modulate.h, modulate.s, 0.5, modulate.a)
func enable() -> void:
	is_disabled = false
	modulate = Color.from_hsv(modulate.h, modulate.s, 1.0, modulate.a)

func change_hp(new_value: int) -> void:
	var change = new_value-hp
	if change <= 0:
		var damage: Label = preload("uid://b878c367s711p").instantiate()
		damage.text = str(change)
		add_child(damage)
	elif change > 0:
		var heal: Label = preload("uid://b878c367s711p").instantiate()
		heal.text = "+" + str(change)
		add_child(heal)
		heal.get_child(0).play("Heal")
	hp = new_value
	hp_container.get_child(0).text = str(hp) + "/" + str(max_hp)
	hp_container.get_child(1).value = hp

# ----- ATTACK -----
func _on_use_attack(attack: String) -> void:
	# Find attack details, apply buffs, etc
	# TODO: enemy choice, apply buffs
	var atk: Attack = attacks[attack]
	var dmg = character.curr_str * (atk.power as float/100)
	var remaining = parent.damage_boss(dmg)
	if remaining >= 0:
		parent.log_attack(character.style.char_name + " used " + attack + "!")

# ----- ACTION -----
func _on_use_action(action: String) -> void:
	# Find action details, set buffs, etc
	var act: Action = actions[action]
	
	# TODO: log later
	parent.log_attack(character.style.char_name + " used " + action + "!")
	if not act.extraLines.is_empty():
		var convo: Conversation = act.extraLines[0]
		if act.extraLines.size() > 1:
			var rand = randi() % (act.extraLines.size()-1)
			convo = act.extraLines[rand]
		parent.dialogue(convo)
	parent.action(character.style.char_name, act)

# ----- ITEM -----
func _on_use_item(_item: String) -> void:
	var idx: int = items.find_custom(func (x): return x.name == _item)
	print("idx") #TODO FIX
	var item: Item = items[idx]
	item.quantity -= 1
	parent.log_attack(character.style.char_name + " used " + _item + "!")
	parent.use_item(item)
