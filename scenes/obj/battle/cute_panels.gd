extends PanelContainer

func set_color(color: Color) -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(color, 0.75)
	add_theme_stylebox_override("panel", stylebox)

func enable() -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	stylebox.set_corner_radius_all(10)
	add_theme_stylebox_override("panel", stylebox)

func disable() -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	stylebox.set_corner_radius_all(30)
	add_theme_stylebox_override("panel", stylebox)
