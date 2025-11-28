extends Node
class_name Story

var story_progress: int = 1

enum Chapter {
	Saga = StoryPoint.Saga_Begins, 
	Jelly = StoryPoint.Alien_Princess, 
	Euphoria = StoryPoint.Sinister_Invasion, 
	Alias = StoryPoint.Secret_Society
}
enum StoryPoint {
	# Flags
	fTest = -2,
	fBoss_Defeated,
	# Default
	Default = 0,
	# Saga
	Saga_Begins = 1,
	Exit_Library,
	# Jelly
	Alien_Princess,
	# Euphoria
	Sinister_Invasion,
	# Alias
	Secret_Society,
}

var flags: Array[bool] = [
	false, #is_boss_defeated
]

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
