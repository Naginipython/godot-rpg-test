extends CombatState

@export var text_ui: TextUI

func enter(_prev: String) -> void:
	#var point: StoryManager.StoryPoint = StoryManager.dialogue_check(player.facing_npc.dialogue.keys())
	var text: Conversation = Conversation.new()
	await get_tree().process_frame # Cute issue with adding to arr and this being called
	for line in combat.lines:
		text.lines.push_back(line)
	
	var boss_line: String = ""
	if combat.boss_hp <= 0:
		boss_line = "Its so OVER!"
	elif combat.boss_hp <= combat.boss_max_hp/2:
		boss_line = "Hey! I'm going to start getting mad ya know!"
	else:
		boss_line = "Why are you attacking me? Is it just because I took over the kingdom? You can just take over a different one too, if you want."
	text.lines.push_back(DialogueLine.new(
		boss_line,
		load("uid://dfcur7lcq1r34"),
		TextUI.Face.Temp
	))
	
	if combat.boss_hp <= 0:
		text.lines.push_back(DialogueLine.new("You gained -- exp!"))
	
	text_ui.enable_text(text)

func _on_text_ui_convo_finished() -> void:
	if not text_ui.is_enabled:
		if combat.boss_hp <= 0:
			GameManager.change_mode(Game.Modes.WORLD)
		else:
			change_state.emit(self, "attackgame")

func exit(_next: String) -> void:
	combat.lines = []
