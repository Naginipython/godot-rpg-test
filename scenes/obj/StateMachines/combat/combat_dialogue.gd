extends CombatState

@export var text_ui: TextUI

func enter(_prev: String) -> void:
	text_ui.temp_disable_face_size()
	#var point: StoryManager.StoryPoint = StoryManager.dialogue_check(player.facing_npc.dialogue.keys())
	var text: Conversation = Conversation.new()
	for line in combat.lines:
		print(line)
		text.lines.push_back(DialogueLine.new(line))
	
	var boss_line: String = ""
	if combat.boss_hp <= combat.boss_max_hp/2:
		boss_line = "Hey! I'm going to start getting mad ya know!"
	else:
		boss_line = "Why are you attacking me? Is it just because I took over the kingdom? You can just take over a different one too, if you want."
	text.lines.push_back(DialogueLine.new(
		boss_line,
		load("res://assets/TextboxStyle/jelly_temp.tres")
	))
	text_ui.enable_text(text)

func process(_delta: float) -> void:
	if not text_ui.is_enabled:
		change_state.emit(self, "attackgame")

func exit(_next: String) -> void:
	combat.lines = []
