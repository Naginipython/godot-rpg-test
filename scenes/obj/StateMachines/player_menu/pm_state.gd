class_name PlayerMenuState
extends State

var menu: PlayerMenu:
	get: return entity as PlayerMenu
# Common methods

func swap_menus(new_menu: String) -> void:
	change_state.emit(self, new_menu)
