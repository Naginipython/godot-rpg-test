extends Control
class_name PlayerMenu

@export var selected: bool = false
var prev_animation_playing: bool = false
var is_disabled = false
# Style
var char_id: String = ""
#var character: CharacterData = preload("uid://cad3qxc5u3kse")
#var img: CompressedTexture2D = preload("uid://cbcfedh8onyr7")
#var color: Color = Color8(255, 81, 112, 255)

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

@warning_ignore_start("unused_signal")
signal prev_turn
signal use_attack(attack: Attack)
signal use_action(action: Action)
signal use_item(item: Item)

func _ready() -> void:
	var ch: CharacterData = GameManager.get_char_data(char_id)
	var stylebox := stats_panel.get_theme_stylebox("panel").duplicate()
	stylebox.set("bg_color", ch.style.color)
	stats_panel.add_theme_stylebox_override("panel", stylebox)
	char_icon.texture = ch.style.portrait
	
	hp = ch.health
	max_hp = ch.curr_max_health
	ch.health_changed.connect(change_hp)
	
	hp_container.get_child(0).text = str(hp) + "/" + str(max_hp)
	hp_container.get_child(1).max_value = max_hp
	hp_container.get_child(1).value = hp
	
	attacks = GameManager.get_attacks(char_id)
	actions = GameManager.get_actions(char_id)
	items = GameManager.items
	setup_btns(attacks.keys(), %AtkBtnsContainer)
	setup_btns(actions.keys(), %ActBtnsContainer)

func _process(_delta: float) -> void:
	$SelectedContainer.visible = selected
	if hp == 0 and not is_disabled:
		disable()

func init_menu(set_character: CharacterData) -> void:
	char_id = set_character.char_id

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
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.from_hsv(modulate.h, modulate.s, 0.5, modulate.a), 0.1)
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

# ----- ITEM -----
func _on_use_item(_item: String) -> void:
	var character: CharacterData = GameManager.get_char_data(char_id)
	var idx: int = items.find_custom(func (x): return x.name == _item)
	print("idx") #TODO FIX
	var item: Item = items[idx]
	item.quantity -= 1
	#parent.log_attack(character.style.char_name + " used " + _item + "!")
	#parent.use_item(item)
