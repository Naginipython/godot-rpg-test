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

var options: PackedStringArray = []
var option_idx: int = 0

signal line_finished
signal convo_finished
signal option_chosen(option: String)

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

# ----- Input methods -----
func pressed_select() -> void:
	if is_enabled:
		if is_printing and can_skip:
			impatient()
		elif text.visible_ratio == 1 and not $OtherThings.visible:
			next()
		elif $OtherThings.visible:
			var btn: Button = %OptionsContainer.get_child(option_idx)
			btn.pressed.emit()

func impatient() -> void:
	if curr_tween: curr_tween.kill()
	text.visible_characters = -1
	_on_line_finished()

func next() -> void:
	if queue.is_empty() and options.is_empty():
		convo_finished.emit()
	elif queue.is_empty() and not options.is_empty():
		enable_options()
	else:
		text.text = ""
		set_line()
		is_printing = true

func option_select(dir: String) -> void:
	if $OtherThings.visible:
		match dir:
			"up": 
				option_idx -= 1
				if option_idx <= -1: option_idx = options.size()-1
			"down": 
				option_idx += 1
				if option_idx >= options.size(): option_idx = 0
		var btn: Button = %OptionsContainer.get_child(option_idx)
		btn.grab_focus()

# ----- Entrance/Exits -----
func enable_text(convo: Conversation) -> void:
	$SkipCooldown.start()
	animation_player.play("enable_text")
	next_text(convo)
	is_enabled = true

func enable_text_w_options(convo: Conversation, _options: PackedStringArray) -> void:
	print("has options")
	options = _options
	option_idx = 0
	enable_text(convo)

func next_text(convo: Conversation) -> void:
	# Used when convos are streaming in
	text.text = ""
	queue = convo.lines.duplicate()
	set_line()

func disable_text() -> void:
	animation_player.play("disable_text")
	await animation_player.animation_finished
	text.text = ""
	setup_char()
	is_enabled = false

func _on_line_finished() -> void:
	is_printing = false
	queue.pop_front()
	emit_signal("line_finished")

# ----- Basic Setups -----
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

# ----- Character Setup -----
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

# Options
func enable_options() -> void:
	$OtherThings.visible = true
	var btn: Button = %OptionsContainer.get_child(0)
	btn.grab_focus()
	btn.text = options[0]
	btn.pressed.connect(_option_btn_pressed.bind(options[0]))
	for i in range(1, options.size()):
		var new_btn = btn.duplicate()
		new_btn.text = options[i]
		new_btn.pressed.connect(_option_btn_pressed.bind(options[i]))
		%OptionsContainer.add_child(new_btn)
	%OptionsContainer.position.y = -10 - %OptionsContainer.get_minimum_size().y

func _option_btn_pressed(data: String) -> void:
	# Todo: signal what is pressed for Lecturn (similar to convo_finished)
	options = []
	# remove option buttons (minus first)
	for i in range(1, %OptionsContainer.get_children().size()):
		%OptionsContainer.remove_child(%OptionsContainer.get_child(i))
	print(%OptionsContainer.get_children())
	# shut off $OtherThings
	$OtherThings.visible = false
	# emit signal with data
	option_chosen.emit(data)

# ----- Etc -----
func _on_skip_cooldown_timeout() -> void:
	can_skip = true
