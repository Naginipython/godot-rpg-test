extends Npc
class_name Lecturn

@export var options: Dictionary[String, Conversation] = {
	"Save Game": null, 
	"Change Party": null, 
	"Nothing": Conversation.new([DialogueLine.new("Good luck!")])
}
@export var swap_menu: SwapMenu

func apply_option(option: String) -> Conversation:
	var result: Conversation = null
	if option.contains("Save"):
		print("game saved (temp)")
	elif option.contains("Change"):
		if not swap_menu: 
			print("Swap Menu not assigned!")
			return
		swap_menu.enable()
		get_tree().paused = true
	elif option.contains("Nothing"):
		result = options[option]
	return result
