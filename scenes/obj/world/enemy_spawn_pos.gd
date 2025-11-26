extends Marker2D

@export var enemy: PackedScene = preload("uid://cteao3keo4fuj")
var is_alive: bool = true

#func _ready() -> void:

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if not Game_singleton.enemies_dead_pos.is_empty():
		if Game_singleton.enemies_dead_pos.find(global_position) != -1:
			is_alive = false
			if $RespawnTimer.is_stopped():
				$RespawnTimer.start()
	if is_alive:
		var enemy_inst = enemy.instantiate()
		enemy_inst.spawnpoint = self
		enemy_inst.global_position = global_position
		get_parent().call_deferred("add_child", enemy_inst)

func _on_respawn_timer_timeout() -> void:
	var this_pos: int = Game_singleton.enemies_dead_pos.find(global_position)
	if this_pos != -1:
		Game_singleton.enemies_dead_pos.remove_at(this_pos)
		is_alive = true
