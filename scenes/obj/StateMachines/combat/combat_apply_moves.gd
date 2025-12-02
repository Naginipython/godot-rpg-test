extends CombatState

func enter(_prev: String) -> void:
	# Take a moves tuple array, data: [Attack/Action/Item, char_id, target]
	for move in combat.moves:
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
	
	#await get_tree().process_frame # Cute issue with adding to arr and this being called
	change_state.emit.call_deferred(self, "dialogue")

func exit(_next: String) -> void:
	combat.moves = []

func apply_attack(atk: Attack, ch: CharacterData, target: String) -> void:
	# Calc dmg from char str
	# Apply buffs/debuffs
	# Log attack & damage
	var dmg = ch.curr_str * (atk.power as float/100)
	combat.boss_hp -= dmg
	var line: String = ch.style.char_name + " used " + atk.name
	if not target.is_empty(): line += "on " + target # TODO
	line += "!"
	print(line)
		
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
