class_name PlayerMenuState
extends State

var menu: PlayerMenu:
	get: return entity as PlayerMenu

# Common methods
# main -> actions mainly
func swap_menus(new_menu: String) -> void:
	change_state.emit(self, new_menu)

# details timer timeout
@onready var show_details_timer: Timer = %ShowDetailsTimer
var is_timer_connected: bool = false
func connect_timer() -> void:
	show_details_timer.timeout.connect(_on_show_details_timer_timeout)
	is_timer_connected = true
func _on_show_details_timer_timeout() -> void:
	enable_details()
func start_timer() -> void:
	if show_details_timer.is_stopped():
		show_details_timer.start()

@onready var main_grid: GridContainer = %MainGrid
@onready var actions_panel: PanelContainer = %ActionsPanel

func get_buttons(container: VBoxContainer) -> Array[Button]:
	var btns: Array[Button] = []
	if not is_timer_connected: connect_timer()
	#container.visible = true
	container.modulate = Color(1,1,1,1)
	for child in container.get_children():
		if child is Button:
			btns.push_back(child)
	return btns

func resize_panel(container: ScrollContainer) -> void:
	var visible_height: float = container.get_size().y
	var total_height: float = container.get_v_scroll_bar().max_value
	var missing_height: float = max(total_height - visible_height, 0)
	actions_panel.size.y += missing_height
	actions_panel.position.y -= missing_height

func scroll_menu_buttons_input(event: InputEvent, btns: Array[Button], btn_idx: int) -> int:
	if event.is_action_pressed("down"):
		disable_details()
		start_timer()
		btn_idx = (btn_idx+1) %btns.size()
		btns[btn_idx].grab_focus()
	if event.is_action_pressed("up"):
		disable_details()
		start_timer()
		if btn_idx-1 == -1:
			btn_idx = btns.size()-1
		else:
			btn_idx = (btn_idx-1) %btns.size()
		btns[btn_idx].grab_focus()
	return btn_idx

func reset_box(container: VBoxContainer) -> void:
	container.modulate = Color(1,1,1,0)
	main_grid.visible = true
	actions_panel.size.y = 100
	actions_panel.position.y = 0

func enable_details() -> void:
	var curr_container: VBoxContainer
	if %DetailsContainer.modulate.a == 0:
		# Change Detail info
		if %AtkBtnsContainer.modulate.a == 1:
			curr_container = %AtkBtnsContainer
			var atk: Attack = menu.attacks[menu.curr_details]
			%DetailsText.text = "Power: " + str(atk.power) + "\n" + atk.desc
		elif %ActBtnsContainer.modulate.a == 1:
			curr_container = %ActBtnsContainer
			var act: Action = menu.actions[menu.curr_details]
			%DetailsText.text = "Effect: "
			match act.type:
				Action.ActionType.Heal: %DetailsText.text += "Heals for +" + str(act.amount)
				Action.ActionType.Buff:
					if act.amount >= 15: %DetailsText.text += "Slight "
					for i in range(0, act.stat.size()):
						if i != 0: %DetailsText.text += ", "
						elif i == act.stat.size()-1 and i != 0: %DetailsText.text += " & "
						%DetailsText.text += CharacterData.BuffableStats.find_key(act.stat[i])
					%DetailsText.text += " buff"
				Action.ActionType.Debuff:
					if act.amount >= 15: %DetailsText.text += "Slight "
					for i in range(0, act.stat.size()):
						if i != 0: %DetailsText.text += ", "
						elif i == act.stat.size()-1 and i != 0: %DetailsText.text += " & "
						%DetailsText.text += CharacterData.BuffableStats.find_key(act.stat[i])
					%DetailsText.text += " enemy debuff"
				Action.ActionType.Revive: %DetailsText.text += "Revives a character"
				_: %DetailsText.text += "lmao TODO"
			if act.is_target_all: %DetailsText.text += ", for all"
			%DetailsText.text += "\n" + act.desc
		elif %ItmBtnsContainer.modulate.a == 1:
			curr_container = %ItmBtnsContainer
			%DetailsText.text = "Effect: "
			var itm_idx: int = menu.items.find_custom(func (x: Item): return x.name == menu.curr_details)
			if itm_idx != -1:
				var itm: Item = menu.items.get(itm_idx)
				match itm.type: 
					Item.ItemType.Heal: %DetailsText.text += "Heals for +" + str(itm.amount)
					Item.ItemType.Buff:
						if itm.amount >= 15: %DetailsText.text += "Slight "
						for i in range(0, itm.stat.size()):
							if i != 0: %DetailsText.text += ", "
							elif i == itm.stat.size()-1 and i != 0: %DetailsText.text += " & "
							%DetailsText.text += CharacterData.BuffableStats.find_key(itm.stat[i])
						%DetailsText.text += " buff"
					Action.ActionType.Debuff:
						if itm.amount >= 15: %DetailsText.text += "Slight "
						for i in range(0, itm.stat.size()):
							if i != 0: %DetailsText.text += ", "
							elif i == itm.stat.size()-1 and i != 0: %DetailsText.text += " & "
							%DetailsText.text += CharacterData.BuffableStats.find_key(itm.stat[i])
						%DetailsText.text += " enemy debuff"
					Action.ActionType.Revive: %DetailsText.text += "Revives a character"
					_: %DetailsText.text += "lmao TODO"
				if itm.is_target_all: %DetailsText.text += ", for all"
		
		# Change y value to button y
		for btn in curr_container.get_children():
			if btn.text.contains(menu.curr_details):
				%DetailsContainer.global_position.y = btn.global_position.y - 10
		
		# animate box
		var tween: Tween = create_tween()
		tween.tween_property(%DetailsContainer, "modulate", Color(1,1,1,1), 0.5)

func disable_details() -> void:
	show_details_timer.stop()
	var details: PanelContainer = %DetailsContainer
	if details.modulate.a > 0:
		var tween: Tween = create_tween()
		tween.tween_property(details, "modulate", Color(1,1,1,0), 0.2)
