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

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var text_char_timer: Timer = $TextCharTimer
@onready var text: Label = %Text
@onready var title: Label = %Title
@onready var portrait: TextureRect = %Portrait
@onready var text_box: PanelContainer = $TextBox
@onready var glow: TextureRect = %Glow

var is_enabled: bool = false
var is_talking: bool = false

var text_queue: Array[String] = []
var face_queue: Array[Face] = []

func _ready() -> void:
	text.text = ""
	title.text = ""
	title.visible = false

#func impatient() -> void:
	#text_char_timer.stop()
	#if text_queue.front():
		#var s: String = text_queue.front()
		#text.text = text.text + s
		#text_queue.pop_front()

func enable_text(npc_data: Npc) -> void:
	if npc_data is SpecialNpc:
		var new_title = npc_data.char_name + ", " + npc_data.title
		setup_char(npc_data.portrait, new_title, npc_data.color)
		setup_dialogue(npc_data.dialogue)
	else:
		setup_char()
		add_array_to_text_queue(npc_data.text)
	#setup_char(new_title, color)
	text.text = ""
	animation_player.play("enable_text")
	is_enabled = true
	text_char_timer.start()

func add_to_text_queue(txt: String) -> void:
	text_queue.push_back(txt)

func add_array_to_text_queue(arr: Array[String]) -> void:
	for txt in arr:
		add_to_text_queue(txt)

func next_text() -> void:
	if text_queue.is_empty():
		animation_player.play("disable_text")
		is_enabled = false
	if text_char_timer.is_stopped():
		text.text = ""
		if not face_queue.is_empty():
			set_face()
		text_char_timer.start()

# ----- Special -----
func setup_char(img: CompressedTexture2D = null, new_title: String = "", color: Color = Color.WHITE) -> void:
	if not new_title.is_empty():
		title.text = new_title
		title.visible = true
	else:
		title.visible = false
	
	if img:
		portrait.visible = true
		var altas: AtlasTexture = portrait.texture
		altas.atlas = img
	else:
		portrait.visible = false
	
	var style: StyleBoxFlat = text_box.get_theme_stylebox("panel")
	style.border_color = color

func add_to_face_queue(face: Face) -> void:
	face_queue.push_back(face)

func setup_dialogue(data: Dictionary) -> void:
	var idx
	if data.has(Game_singleton.story_progress):
		idx = Game_singleton.story_progress
	else:
		idx = -1
	for tuple in data[idx]:
		add_to_face_queue(tuple[0])
		add_to_text_queue(tuple[1])
	set_face()

func set_face() -> void:
	var face: Face = face_queue.pop_front()
	var pic: AtlasTexture = portrait.texture
	pic.region = Rect2(face_pos[face], Vector2(40,40))
	change_emotion(face)

func change_emotion(new_emotion: Face) -> void:
	if new_emotion in emotion_colors:
		var tween = create_tween()
		tween.tween_property(glow, "modulate", emotion_colors[new_emotion], 0.2)

func _on_text_char_timer_timeout() -> void:
	if visible and not animation_player.is_playing():
		if text_queue.front():
			var s: String = text_queue.front()
			var c: String = s[0]
			text.text = text.text + c
			if s.length() == 1:
				text_queue.pop_front()
			else:
				text_char_timer.start()
				text_queue[0] = s.substr(1)
	elif visible:
		text_char_timer.start()
