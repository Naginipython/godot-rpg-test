extends Resource
class_name Item

enum ItemType {
	Buff, Debuff, Heal, Revive
}

@export var name: String
@export var desc: String
@export var type: ItemType
@export var amount: int # Of type
@export var quantity: int
@export var is_target_all: bool

func _init(
	_name: String, 
	_desc: String = "", 
	_type: ItemType = ItemType.Buff, 
	_amount: int = 0,
	_quantity: int = 0,
	_is_target_all: bool = false
) -> void:
	name = _name
	desc = _desc
	type = _type
	amount = _amount
	quantity = _quantity
	is_target_all = _is_target_all

enum CommonItems {
	SmHpPot,
	MedHpPot,
	LrgHpPot,
	# SmSplshHpPot
	# etc
}

static func createCommonItem(item: CommonItems, _quantity: int) -> Item:
	match item:
		CommonItems.SmHpPot:
			return Item.new(getCommonName(CommonItems.SmHpPot), "The classic", ItemType.Heal, 20, _quantity)
		CommonItems.MedHpPot:
			return Item.new(getCommonName(CommonItems.MedHpPot), "The classic, bigger!", ItemType.Heal, 50, _quantity)
		CommonItems.LrgHpPot:
			return Item.new(getCommonName(CommonItems.LrgHpPot), "The classic, biggest!", ItemType.Heal, 100, _quantity)
	return Item.new("Missingno", "Oops", ItemType.Heal, 0)

static func getCommonName(item: CommonItems) -> String:
	match item:
		CommonItems.SmHpPot:
			return "Small HP Potion"
		CommonItems.MedHpPot:
			return "Medium HP Potion"
		CommonItems.LrgHpPot:
			return "Large Hp Potion"
	return "Missingno"
