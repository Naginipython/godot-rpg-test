extends MarginContainer
class_name TextUI

enum Face {
	Happy, Sad, Surpirsed, Temp
}
var face_pos: Dictionary[Face, Rect2] = {
	Face.Happy: Rect2(0,0,40,40),
	Face.Sad: Rect2(80,0,40,40),
	Face.Surpirsed: Rect2(80,80,40,40),
	Face.Temp: Rect2(0,0,0,0)
}
var emotion_colors: Dictionary[Face, Color] = {
	Face.Happy: Color(1.0, 1.0, 0.0, 1.0),
	Face.Sad: Color(0.0, 0.0, 1.0, 1.0),
	Face.Surpirsed: Color(0.0, 1.0, 1.0, 1.0)
}

# UI variables
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var text: RichTextLabel = %Text
@onready var title: RichTextLabel = %Title
@onready var portrait: TextureRect = %Portrait
@onready var text_box: PanelContainer = $TextBox
@onready var glow: TextureRect = %Glow

var is_enabled: bool = false #used for player state talking -> main in player_talking.gd
var queue: Array[DialogueLine] = []
var is_printing: bool = true #used to check if it's printing
var speed_per_char = 0.02
var curr_tween: Tween
var can_skip = false

signal line_finished
signal convo_finished

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and is_enabled:
		if is_printing and can_skip:
			impatient()
		else:
			next_text()

func enable_text(convo: Conversation) -> void:
	$SkipCooldown.start()
	animation_player.play("enable_text")
	text.text = ""
	queue = convo.lines.duplicate()
	set_line()
	is_enabled = true

func disable_textbox() -> void:
	animation_player.play("disable_text")
	await animation_player.animation_finished
	text.text = ""
	setup_char()
	is_enabled = false
	convo_finished.emit()

func set_line() -> void:
	can_skip = false
	$SkipCooldown.start()
	if not queue.is_empty():
		setup_char(queue[0].speaker)
		
		text.text = queue[0].text
		text.visible_characters = 0
		is_printing = true
		
		var char_count = text.get_total_character_count()
		var duration = char_count * speed_per_char
		
		if curr_tween: curr_tween.kill()
		curr_tween = create_tween()
		
		curr_tween.tween_property(text, "visible_characters", char_count, duration)
		curr_tween.finished.connect(_on_line_finished)

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
	else:
		text.text = ""
		set_line()
		is_printing = true

func set_face() -> void:
	if queue.front():
		var face: Face = queue.front().face
		var pic: AtlasTexture = portrait.texture
		pic.region = face_pos[face]
		change_emotion(face)

func change_emotion(new_emotion: Face) -> void:
	if new_emotion in emotion_colors:
		var tween = create_tween()
		tween.tween_property(glow, "modulate", emotion_colors[new_emotion], 0.2)

func impatient() -> void:
	if curr_tween: curr_tween.kill()
	text.visible_characters = -1
	_on_line_finished()

func _on_line_finished() -> void:
	is_printing = false
	queue.pop_front()
	emit_signal("line_finished")

func _on_skip_cooldown_timeout() -> void:
	can_skip = true
