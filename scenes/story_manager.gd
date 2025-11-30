extends Node
class_name Story

var story_progress: int = 1

enum Chapter {
	Saga = StoryPoint.SagaBegins, 
	Jelly = StoryPoint.AlienPrincess, 
	Euphoria = StoryPoint.SinisterInvasion, 
	Alias = StoryPoint.SecretSociety
}
enum StoryPoint {
	# Flags
	fTest = -2,
	fBossDefeated,
	# Default
	Default = 0,
	# Saga
	SagaBegins = 1,
	StartGame,
	NewArea,
	# Jelly
	AlienPrincess,
	# Euphoria
	SinisterInvasion,
	# Alias
	SecretSociety,
}

var flags: Array[bool]

func _ready() -> void:
	var flagAmount: int = 2
	for f in flagAmount:
		flags.push_back(false)

func story_point_from_string(point: String) -> StoryPoint:
	var result = StoryPoint.get(point, 0)
	return result

func dialogue_check(keys: Array[StoryPoint]) -> StoryPoint:
	# If a flag is checked, use that
	for i in flags.size():
		if flags[i]:
			if keys.has(((i+1) * -1) as StoryPoint):
				print((i+1) * -1)
				return ((i+1)*-1) as StoryPoint
	
	# Check keys for floored story point
	var pfloor: StoryPoint = StoryPoint.Default
	for point in keys:
		if point as int <= story_progress:
			pfloor = point
		else:
			return pfloor
	return pfloor

func enable_flag(point: StoryPoint) -> void:
	# flags need to be negative
	if point as int >= 0: return
	var idx: int = abs(point as int) -1
	if idx < flags.size():
		flags[idx] = true

func disable_flag(point: StoryPoint) -> void:
	# flags need to be negative
	if point as int >= 0: return
	var idx: int = abs(point as int) -1
	if idx < flags.size():
		flags[idx] = false

func reset_flags() -> void:
	for i in flags.size():
		flags[i] = false
