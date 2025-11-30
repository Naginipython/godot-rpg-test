extends Resource
class_name Action

enum ActionType {
	AdditionBuff, MultiplyBuff, AdditionDebuff, MultiplyDebuff, Heal
}

# Action: { desc, class, amount, animation, extraLines(Array<Convo>), etc }
@export var name: String
@export var desc: String
@export var type: ActionType
@export var amount: int
@export var extraLines: Array[Conversation]
