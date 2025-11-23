extends CharacterBody2D
class_name Player

@export var text_ui: TextUI

var npcs_in_range: Array[Npc] = []
var facing_npc: Npc

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("select"):
		#if world_ui.is_enabled:
			#world_ui.next_text()
		#else:
			#world_ui.enable_text()
		
