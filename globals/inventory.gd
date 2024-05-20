extends Node

const ITEMS: String = "items"
const LIMIT: String = "limit"
const AMOUNT: String = "amount"
const NAME: String = "name"

enum Item {
	Healing,
	Headache
}

var _itemName: Dictionary = {
	Item.Healing: "healing",
	Item.Headache: "headache"
}

var _inventory: Dictionary = {
	ITEMS: {
		Item.Healing: {
			NAME: _itemName[Item.Healing],
			AMOUNT: 0,
			LIMIT: 10,
		},
		Item.Headache: {
			NAME: _itemName[Item.Headache],
			AMOUNT: 6,
			LIMIT: 10,
		},
	},
}

func add_item(item: Item, amount: int = 1):
	_inventory[ITEMS][item][AMOUNT] += amount
	if _inventory[ITEMS][item][AMOUNT] >= _inventory[ITEMS][item][LIMIT]:
		_inventory[ITEMS][item][AMOUNT] = _inventory[ITEMS][item][LIMIT]

func remove_item(item: Item, amount: int = 1):
	_inventory[ITEMS][item][AMOUNT] -= amount
	if _inventory[ITEMS][item][AMOUNT] <= 0:
		_inventory[ITEMS][item][AMOUNT] = 0

func get_item(item: Item):
	return _inventory[ITEMS][item]

func get_items():
	return _inventory[ITEMS]
