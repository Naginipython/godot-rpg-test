extends Resource
class_name Action

enum ActionType {
	AddBuff, MultBuff, AddDebuff, MultDebuff, Heal
}

# Action: { desc, class, amount, animation, extraLines(Array<Convo>), etc }
@export var name: String
@export var desc: String
@export var type: ActionType
@export var stat: CharacterData.BuffableStats
@export var amount: int
@export var is_target_all: bool
@export var can_target_self: bool
@export var extraLines: Array[Conversation]
