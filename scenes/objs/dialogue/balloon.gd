extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

signal ended

@export var characterStyles: Dictionary[String, TextboxStyle] = {
	"combee": preload("uid://dp2fw6x1c4vrw"),
	"nitya": preload("uid://cl5hcv1dii2qg"),
	"rotom": preload("uid://c3o1r2ep47fyq"),
	"clio": preload("uid://1cxfa074ov6r"),
	"wilhelmina": preload("uid://idpvsui3d4en")
}

enum Face {
	Happy, Excited, Worried, Shocked, Temp
}
var face_pos: Dictionary[Face, Rect2] = {
	Face.Happy: Rect2(0,0,40,40), # left,down,width/height
	Face.Excited: Rect2(40,0,40,40), # Rotom only
	Face.Worried: Rect2(80,0,40,40),
	Face.Shocked: Rect2(80,80,40,40),
	Face.Temp: Rect2(0,0,0,0), # Non-Pokemon
}
var emotion_colors: Dictionary[Face, Color] = {
	Face.Happy: Color(1.0, 1.0, 0.0, 1.0),
	Face.Excited: Color(0.0, 1.0, 0.0, 1.0),
	Face.Worried: Color(0.0, 0.0, 1.0, 1.0),
	Face.Shocked: Color(0.0, 1.0, 1.0, 1.0),
	Face.Temp: Color(1.0, 1.0, 1.0, 1.0),
}

## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given cue when using balloon as a [Node] in a scene.
@export var start_from_cue: String = ""

## If running as a [Node] in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
@export var will_block_other_input: bool = true

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## A sound player for voice lines (if they exist).
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			ended.emit()
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

@onready var textbox: PanelContainer = %Textbox

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

@onready var character_portrait: TextureRect = %Portrait

@onready var character_glow: TextureRect = %Glow

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Indicator to show that player can progress dialogue.
@onready var progress: Polygon2D = %Progress


func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = &"select"

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()



func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = not dialogue_label.is_typing and dialogue_line.responses.size() == 0 and not dialogue_line.has_tag("voice")


func _unhandled_input(_event: InputEvent) -> void:
# Only the balloon is allowed to handle input while it's showing
	if will_block_other_input:
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if not responses_menu.is_visible_in_tree():
		return

	var direction := 0
	if event.is_action_pressed("up"):
		direction = -1
	elif event.is_action_pressed("down"):
		direction = 1
	else:
		return

	var items := responses_menu.get_menu_items()
	var current_index := items.find(get_viewport().gui_get_focus_owner())
	if current_index == -1:
		return

	var next_index := clampi(current_index + direction, 0, items.size() - 1)
	items[next_index].grab_focus()
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		await dialogue_line.refresh()
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(with_dialogue_resource: DialogueResource = null, cue: String = "", extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not cue.is_empty():
		start_from_cue = cue
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, temporary_game_states)
	show()


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	# Get game singleton character & apply it to style, portrait, and character_label
	var name_and_maybe_emotion: PackedStringArray = dialogue_line.character.split(",")
	if not dialogue_line.character.is_empty() and characterStyles.has(name_and_maybe_emotion[0]):
		setup_character(name_and_maybe_emotion)
	else:
		character_label.visible = false
		character_portrait.visible = false
		character_label.text = "Missingo"
		

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for next line
	if dialogue_line.has_tag("voice"):
		audio_stream_player.stream = load(dialogue_line.get_tag_value("voice"))
		audio_stream_player.play()
		await audio_stream_player.finished
		next(dialogue_line.next_id)
	elif dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
		responses_menu.focus_first_item()
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## Go to the next line
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)

func setup_character(name_and_maybe_emotion: Array[String]) -> void:
	var speaker: TextboxStyle = characterStyles[name_and_maybe_emotion[0]]
	var img: CompressedTexture2D = null
	var new_title: String = ""
	var color: Color = Color.WHITE
	var emotion: Face = Face.Happy
	
	if speaker:
		img = speaker.portrait
		new_title = speaker.char_name + ", " + speaker.title
		color = speaker.color
		if name_and_maybe_emotion.size() > 1:
			emotion = string_to_face(name_and_maybe_emotion[1])
	
	if name_and_maybe_emotion[0] not in ["rotom", "combee"]:
		emotion = Face.Temp
	
	if not new_title.is_empty():
		character_label.visible = true
		character_label.text = new_title
	else:
		print("Error: No title for speaker: " + speaker.to_string())
	
	if img:
		character_portrait.visible = true
		var altas: AtlasTexture = character_portrait.texture
		altas.atlas = img
		set_face(emotion)
	else:
		print("Error: No title for speaker: " + speaker.to_string())
		
	var box: StyleBoxFlat = textbox.get_theme_stylebox("panel")
	box.border_color = speaker.color

func set_face(face: Face) -> void:
	var pic: AtlasTexture = character_portrait.texture
	pic.region = face_pos[face]
	change_emotion(face)

func change_emotion(new_emotion: Face) -> void:
	if new_emotion in emotion_colors:
		var tween = create_tween()
		tween.tween_property(character_glow, "modulate", emotion_colors[new_emotion], 0)

func string_to_face(s: String) -> Face:
	match s:
		"happy": 
			return Face.Happy
		"excited":
			return Face.Excited
		"worried":
			return Face.Worried
		"shocked":
			return Face.Shocked
		"temp":
			return Face.Temp
	
	return Face.Happy

#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		#var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var was_select_clicked: bool = event.is_action_pressed("select")
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if was_select_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	#if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
	if event.is_action_pressed("select"):
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


#endregion
