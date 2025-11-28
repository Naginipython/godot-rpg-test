extends CharacterBody2D
class_name Player

@export var world: Node
@export var text_ui: TextUI
@export var cutscene_player: AnimationPlayer

var npcs_in_range: Array[Npc] = []
var facing_npc: Npc

var cutscene_area: Area2D
