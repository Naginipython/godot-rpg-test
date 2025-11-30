extends Resource
class_name DialogueLine

@export var text: String
@export var speaker: TextboxStyle
@export var face: TextUI.Face = TextUI.Face.Happy

func _init(_text: String = "", _speaker: TextboxStyle = null, _face: TextUI.Face = TextUI.Face.Happy) -> void:
	text = _text
	speaker = _speaker
	face = _face
