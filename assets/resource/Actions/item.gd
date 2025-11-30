extends Resource
class_name Item

enum ItemType {
	AddBuff, MultBuff, AddDebuff, MultDebuff, SingleHeal, MultHeal
}

@export var name: String
@export var desc: String
@export var type: ItemType
@export var amount: int # Of type
@export var quantity: int

func _init(
	_name: String, 
	_desc: String = "", 
	_type: ItemType = ItemType.AddBuff, 
	_amount: int = 0,
	_quantity: int = 0
) -> void:
	name = _name
	desc = _desc
	type = _type
	amount = _amount
	quantity = _quantity

enum CommonItems {
	SmHpPot,
	MedHpPot,
	LrgHpPot
}

static func createCommonItem(item: CommonItems, _quantity: int) -> Item:
	match item:
		CommonItems.SmHpPot:
			return Item.new(getCommonName(CommonItems.SmHpPot), "The classic", ItemType.SingleHeal, 20, _quantity)
		CommonItems.MedHpPot:
			return Item.new(getCommonName(CommonItems.MedHpPot), "The classic, bigger!", ItemType.SingleHeal, 50, _quantity)
		CommonItems.LrgHpPot:
			return Item.new(getCommonName(CommonItems.LrgHpPot), "The classic, biggest!", ItemType.SingleHeal, 100, _quantity)
	return Item.new("Missingno", "Oops", ItemType.SingleHeal, 0)

static func getCommonName(item: CommonItems) -> String:
	match item:
		CommonItems.SmHpPot:
			return "Small HP Potion"
		CommonItems.MedHpPot:
			return "Medium HP Potion"
		CommonItems.LrgHpPot:
			return "Large Hp Potion"
	return "Missingno"
