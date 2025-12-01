extends PlayerMenuState

@onready var selected_container: CenterContainer = %SelectedContainer
@onready var stats_panel: PanelContainer = %StatsPanel
@onready var actions_panel: PanelContainer = %ActionsPanel
@onready var main_grid: GridContainer = %MainGrid

var enable_arrow_bounce: bool = true
var arrow_bounce_up: bool = true
var arrow_bounce_speed: float = 0.5

func enter(_prev: String) -> void:
	# For development
	stats_panel.visible = true
	actions_panel.visible = true
	main_grid.visible = true

func unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("select") and 
		menu.selected and 
		not menu.animation_player.is_playing() and
		not menu.prev_animation_playing):
		change_state.emit(self, "actions")

func process(_delta: float) -> void:
	arrow_bounce()

func arrow_bounce() -> void:
	if enable_arrow_bounce:
		if arrow_bounce_up:
			selected_container.size.y += arrow_bounce_speed
			selected_container.position.y -= arrow_bounce_speed
			if selected_container.size.y > 90:
				selected_container.size.y = 90
				selected_container.position.y = -90
				arrow_bounce_up = false
		else:
			selected_container.size.y -= arrow_bounce_speed
			selected_container.position.y += arrow_bounce_speed
			if selected_container.size.y < 70:
				selected_container.size.y = 70
				selected_container.position.y = -70
				arrow_bounce_up = true
	else:
		selected_container.size.y = 70
		selected_container.position.y = -70
		arrow_bounce_up = true
