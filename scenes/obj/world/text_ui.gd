extends MarginContainer
class_name TextUI

enum Face {
	Happy, Sad, Surpirsed
}
var face_pos: Dictionary[Face, Vector2] = {
	Face.Happy: Vector2(0,0),
	Face.Sad: Vector2(80,0),
	Face.Surpirsed: Vector2(80,80)
}
var emotion_colors: Dictionary[Face, Color] = {
	Face.Happy: Color(1.0, 1.0, 0.0, 1.0),
	Face.Sad: Color(0.0, 0.0, 1.0, 1.0),
	Face.Surpirsed: Color(0.0, 1.0, 1.0, 1.0)
}
var temp_face_size: Vector2 = Vector2(40,40)

# UI variables
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var text_char_timer: Timer = $TextCharTimer
@onready var text: Label = %Text
@onready var title: Label = %Title
@onready var portrait: TextureRect = %Portrait
@onready var text_box: PanelContainer = $TextBox
@onready var glow: TextureRect = %Glow

var is_enabled: bool = false #used for player state talking -> main in player_talking.gd
var is_printing: bool = true #used to check if it's printing

var text_queue: Array[String] = []
var face_queue: Array[Face] = []

var char_idx = 0
var queue: Array[DialogueLine] = []

func _ready() -> void:
	text.text = ""
	title.text = ""
	title.visible = false
	animation_player.play("RESET")

func _process(_delta: float) -> void:
	# Make [>>>] go [ >>] [>>>] [> >] [>>>] [>> ]
	# when current text is finished.
	if is_printing:
		%EndHintLabel.modulate = Color(1,1,1,0)
	else:
		%EndHintLabel.modulate = Color(1,1,1,1)

func temp_disable_face_size() -> void:
	temp_face_size = Vector2(0,0)

func enable_text(convo: Conversation) -> void:
	animation_player.play("enable_text")
	text.text = ""
	is_enabled = true
	queue = convo.lines.duplicate()
	set_line()
	text_char_timer.start()

func disable_textbox() -> void:
	temp_face_size = Vector2(40,40)
	animation_player.play("disable_text")
	is_enabled = false

func set_line() -> void:
	if not queue.is_empty():
		char_idx = 0
		setup_char(queue[0].speaker)

func setup_char(speaker: TextboxStyle = null) -> void:
	var img: CompressedTexture2D = null
	var new_title: String = ""
	var color: Color = Color.WHITE
	if speaker:
		img = speaker.portrait
		new_title = speaker.char_name + ", " + speaker.title
		color = speaker.color
		
	if not new_title.is_empty():
		title.text = new_title
		title.visible = true
	else:
		title.visible = false
	
	if img:
		portrait.visible = true
		var altas: AtlasTexture = portrait.texture
		altas.atlas = img
		set_face()
	else:
		portrait.visible = false
	
	var style: StyleBoxFlat = text_box.get_theme_stylebox("panel")
	style.border_color = color

func next_text() -> void:
	if queue.is_empty():
		disable_textbox()
	if text_char_timer.is_stopped():
		text.text = ""
		set_line()
		text_char_timer.start()

func set_face() -> void:
	if queue.front():
		var face: Face = queue.front().face
		var pic: AtlasTexture = portrait.texture
		pic.region = Rect2(face_pos[face], temp_face_size)
		change_emotion(face)

func change_emotion(new_emotion: Face) -> void:
	if new_emotion in emotion_colors:
		var tween = create_tween()
		tween.tween_property(glow, "modulate", emotion_colors[new_emotion], 0.2)

func _on_text_char_timer_timeout() -> void:
	if visible and not animation_player.is_playing():
		is_printing = true
		if queue.front():
			var d: DialogueLine = queue.front()
			text.text += d.text[char_idx]
			char_idx += 1
			if d.text.length() <= char_idx:
				is_printing = false
				queue.pop_front()
			else:
				text_char_timer.start()
	elif visible:
		text_char_timer.start()
