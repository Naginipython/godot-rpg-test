extends CombatState

# TODO: combine dialogue, so text aligns with applying (for animation later)
# TODO: items, action buffs, attack buffing
@onready var text_ui: TextUI = $"../../CanvasLayer/TextUI"
var is_finished: bool

func enter(_prev: String) -> void:
	# Take a moves tuple array, data: [Attack/Action/Item, char_id, target]
	is_finished = false
	use_move()
	#await get_tree().process_frame # Cute issue with adding to arr and this being called
	#change_state.emit.call_deferred(self, "dialogue")

func exit(_next: String) -> void:
	combat.moves = []

# _on_convo_finished: next move -> TextUI -> convo_finished -> nextmove
# Leave when moves is empty
func _on_text_ui_convo_finished() -> void:
	if not use_move() and not is_finished: # uses move, does below when no more moves
		var text: Conversation = Conversation.new()
		temp_boss_lines(text)
		
		if combat.boss_hp <= 0:
			text.lines.push_back(DialogueLine.new("You gained -- exp!"))
		
		text_ui.enable_text(text)
		is_finished = true
	elif is_finished:
		if combat.boss_hp <= 0:
			GameManager.change_mode(Game.Modes.WORLD)
		else:
			change_state.emit(self, "attackgame")
	

func use_move() -> bool:
	if combat.moves.is_empty(): return false
	
	var move = combat.moves.front()
	var ch: CharacterData = GameManager.get_char_data(move[1])
	var target_id: String = ""
	if move.size() >= 3:
		target_id = move[2]
		
	if move[0] is Attack:
		apply_attack(move[0], ch, target_id)
	if move[0] is Action:
		apply_action(move[0], ch, target_id)
	if move[0] is Item:
		# Apply buff/heal/debuff/revive (move[2] is target)
		# Log who used item & effect/heal on who
		pass
	# Dialogue
	var text: Conversation = Conversation.new()
	text.lines = combat.lines
	text_ui.enable_text(text)
	combat.lines.clear()
	combat.moves.pop_front()
	return true

func apply_attack(atk: Attack, ch: CharacterData, target: String) -> void:
	# Calc dmg from char str
	# Apply buffs/debuffs
	# Log attack & damage
	var dmg = ch.curr_str * (atk.power as float/100)
	combat.boss_hp -= dmg
	var line: String = ch.style.char_name + " used " + atk.name
	if not target.is_empty(): line += "on " + target # TODO
	line += "!"
		
	combat.lines.push_back(DialogueLine.new(line))

func apply_action(act: Action, ch: CharacterData, target: String) -> void:
	# Deal with dialogue
	var line: String = ch.style.char_name + " used " + act.name
	if not target.is_empty(): 
		var ch2 = GameManager.get_char_data(target)
		if ch2:
			line += " on " + ch2.style.char_name # TODO
	line += "!"
	combat.lines.push_back(DialogueLine.new(line))
	
	if not act.extraLines.is_empty():
		var convo: Conversation = act.extraLines[0]
		if act.extraLines.size() > 1:
			var rand = randi() % (act.extraLines.size()-1)
			convo = act.extraLines[rand]
		for _line in convo.lines:
			combat.lines.push_back(_line)
	
	# Set buffs/debuffs/heals
	match act.type:
		# ----- HEAL -----
		Action.ActionType.Heal:
			if act.is_target_all:
				pass # todo
			else:
				if not target.is_empty(): 
					var ch2 = GameManager.get_char_data(target)
					if ch2:
						ch2.health += act.amount
		# ----- idk -----
		_:
			print("oops not made yet")

func temp_boss_lines(text: Conversation) -> void:
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
