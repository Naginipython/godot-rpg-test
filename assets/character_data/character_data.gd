class_name CharacterData
extends Resource
# Credit: https://www.youtube.com/watch?v=vsBb9921GfA

signal initialized(character: CharacterData)
signal health_changed(new_value: int)

@export_group("Basic")
@export var char_id: String = ""
@export var active: bool = false
@export var style: TextboxStyle = preload("uid://cl5hcv1dii2qg")

# Combat
@export_group("Combat")
#@export var party_order: int = 0
@export var expr: int = 0: set = _on_exp_set
@export var base_max_health: int = 100
@export var base_str: int = 10 # Damage is str * (move_power/10)
@export var base_def: int = 10
@export var base_spd: int = 10
@export var base_acc: int = 10
@export var base_evad: int = 10
# Move: { desc, power, effect, animation, idk }
@export var attacks: Dictionary[String, Attack] = {}
# Action: { desc, class, amount, animation, extraLines(Array<Convo>), etc }
@export var actions: Dictionary[String, Action] = {}

enum BuffableStats { HP, STR, DEF, SPD, ACC, EVAD }
const STAT_CURVES: Dictionary[BuffableStats, Curve] = {
	BuffableStats.HP: preload("uid://cx746drrg0ful"),
	BuffableStats.STR: preload("uid://di1hk5i0erd8x"),
	BuffableStats.DEF: preload("uid://dmqyjob3rorx4"),
	BuffableStats.SPD: preload("uid://b2vqmhe4b4irx"),
	#BuffableStats.ACC: preload("uid://dmqyjob3rorx4"),
	#BuffableStats.EVAD: preload("uid://dmqyjob3rorx4"),
}

var level: int:
	get(): return floor(max(1.0, sqrt(expr / 100.0) + 0.5))
var curr_max_health: int = 100
var curr_str: int = 10
var curr_def: int = 10
var curr_spd: int = 10
var curr_acc: int = 10
var curr_evad: int = 10

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
	@warning_ignore_start("narrowing_conversion")
	curr_max_health = base_max_health * STAT_CURVES[BuffableStats.HP].sample(stat_sample_pos)
	curr_str = base_str * STAT_CURVES[BuffableStats.STR].sample(stat_sample_pos)
	curr_def = base_def * STAT_CURVES[BuffableStats.DEF].sample(stat_sample_pos)
	curr_spd = base_spd * STAT_CURVES[BuffableStats.SPD].sample(stat_sample_pos)
	#curr_acc = base_acc * STAT_CURVES[BuffableStats.ACC].sample(stat_sample_pos)
	#curr_evad = base_evad * STAT_CURVES[BuffableStats.EVAD].sample(stat_sample_pos)

func _on_health_set(new_value: int) -> void:
	health = clampi(new_value, 0, curr_max_health)
	health_changed.emit(health)
	#if health == 0:
		#dead.emit() # For a signal system

func _on_exp_set(new_value: int) -> void:
	var old_lvl: int = level
	expr = new_value
	if not old_lvl == level:
		recalculate_stats()
