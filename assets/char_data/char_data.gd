extends Resource
class_name CharacterData
# Credit: https://www.youtube.com/watch?v=vsBb9921GfA

signal initialized(character: CharacterData)
signal health_changed(new_value: int)

# Basic
@export_group("Basic")
@export var char_id: String = ""
@export var style: TextboxStyle = preload("uid://rgjmc231x4f3")

# Combat
@export_group("Combat")
@export var active: bool = false
#@export var party_order: int = 0
@export var expr: int = 0: set = _on_exp_set
@export var base_max_health: int = 100
@export var base_str: int = 10 # Damage is str * (move_power/10)
@export var base_def: int = 10
@export var base_spd: int = 10
@export var attacks: PackedStringArray = []
# Move: { desc, power, effect, animation, idk }
@export var attack_details: Dictionary[String, Dictionary] = {}

enum BuffableStats { MAX_HEALTH, STR, DEF, SPD }
const STAT_CURVES: Dictionary[BuffableStats, Curve] = {
	BuffableStats.MAX_HEALTH: preload("uid://dohe3fy834op7"),
	BuffableStats.STR: preload("uid://bp7di76adwpav"),
	BuffableStats.DEF: preload("uid://cclgsyrbicql1"),
	BuffableStats.SPD: preload("uid://bfw3phwk4kthv")
}

var level: int:
	get(): return floor(max(1.0, sqrt(expr / 100.0) + 0.5))
var curr_max_health: int = 100
var curr_str: int = 10
var curr_def: int = 10
var curr_spd: int = 10

var health: int = 100: set = _on_health_set

func _init() -> void:
	setup_stats.call_deferred()

func setup_stats() -> void:
	recalculate_stats()
	health = curr_max_health
	initialized.emit(self)

func is_alive() -> bool:
	return health > 0

func recalculate_stats() -> void:
	var stat_sample_pos: float = (float(level) / 100.0) - 0.01
	curr_max_health = base_max_health * STAT_CURVES[BuffableStats.MAX_HEALTH].sample(stat_sample_pos)
	curr_str = base_str * STAT_CURVES[BuffableStats.STR].sample(stat_sample_pos)
	curr_def = base_def * STAT_CURVES[BuffableStats.DEF].sample(stat_sample_pos)
	curr_spd = base_spd * STAT_CURVES[BuffableStats.SPD].sample(stat_sample_pos)

func _on_health_set(new_value: int) -> void:
	health = clampi(new_value, 0, curr_max_health)
	health_changed.emit(health)
	#print(health)
	#if health == 0:
		#dead.emit() # For a signal system

func _on_exp_set(new_value: int) -> void:
	var old_lvl: int = level
	expr = new_value
	if not old_lvl == level:
		recalculate_stats()
