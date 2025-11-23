extends Npc
class_name SpecialNpc

@export var char_name: String = "Combee"
@export var title: String = "Destroyer of Worlds"
@export var portrait: CompressedTexture2D = preload("uid://dux88ljpoq63i")
@export var color: Color = Color(1.0, 1.0, 0.0, 1.0)
@export var dialogue: Dictionary[int, Array] = {
	-1: [
		[TextUI.Face.Happy, "Hello"],
		[TextUI.Face.Happy, "This is a special test"]
	],
	1: [
		[TextUI.Face.Sad, "I really liked that guy"],
		[TextUI.Face.Sad, "Killing is wrong, I advise you don't do it again"]
	]
}
