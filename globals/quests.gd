extends Node

signal new_house(house: Dictionary)
signal quest_ended(quest: Dictionary)
signal game_over

enum SickType {
	Headache,
	Abdominal,
	Joints
}

var sick_name: Dictionary = {
	SickType.Headache: "head",
	SickType.Abdominal: "tummy",
	SickType.Joints: "elbow",
}

enum QuestType {
	Delivery,
	PunchCard,
	PunchCardDelivery,
}

enum House {
	House1,
	House2,
	House3,
	House4,
	House5,
	House6,
	House7,
	House8,
	Doc_House,
	OTHER,
}

var current_house: Dictionary

var completed_quests: int = 0
var amount_to_win: int = 3

func _ready():
	quest_ended.connect(_on_quest_ended)

func _on_quest_ended():
	houses.erase(current_house["name"])
	completed_quests += 1
	current_house = {}
	if completed_quests >= amount_to_win:
		game_over.emit()

func current_quest_part_completed():
	current_house["quest"] = current_house["quest"]["reward"]
	if !current_house["quest"]:
		quest_ended.emit()
		UI.hint.emit("get new pain card from the doc")
		return
	match current_house["quest"]["sub_type"]:
		Quests.QuestType.PunchCardDelivery:
			UI.hint.emit("deliver card to the house")
		Quests.QuestType.PunchCard:
			UI.hint.emit("deliver card back to doc")
		Quests.QuestType.Delivery:
			UI.hint.emit("deliver medicaments to the house")

func get_current_house():
	if current_house:
		return current_house
	if completed_quests >= amount_to_win:
		game_over.emit()
		return
	current_house = houses[houses.keys().pick_random()]
	return current_house

func generate_quests(type: QuestType = QuestType.PunchCardDelivery, amount: int = 1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(amount):
		result.push_back(generate_quest(type))
	return result

func generate_quest(type: QuestType = QuestType.PunchCardDelivery, value: Dictionary = {}, _depth: int = 1) -> Dictionary:
	var result = {
		"type": "quest",
		"sub_type": type,
	}
	var requirements_amount: int = randi_range(1, SickType.size())
	if !value:
		var val: Dictionary = {}
		for i in requirements_amount:
			val[SickType.values().pick_random()] = randi_range(1, 5)
		result["value"] = val
	else:
		result["value"] = value
	match type:
		QuestType.PunchCardDelivery:
			result["reward"] = generate_quest(QuestType.PunchCard, result["value"])
		QuestType.Delivery:
			result["reward"] = {}
			result["message"] = "thanks, you helped me with my " + sick_name[value.keys().pick_random()]
		QuestType.PunchCard:
			result["reward"] = generate_quest(QuestType.Delivery, result["value"])
	return result

var houses: Dictionary = {
	House.House1: {
		"name": House.House1,
		"quest": generate_quest(QuestType.PunchCardDelivery),
		"features": [
			"blue roof",
			"one floor",
			"short",
			"smoll",
			"light is on"
		],
	},
	House.House2: {
		"name": House.House2,
		"quest": generate_quest(QuestType.PunchCardDelivery),
		"features": [
			"red roof",
			"two floors",
			"light is on",
			"looks like a plus",
		],
	},
	House.House3: {
		"name": House.House3,
		"quest": generate_quest(QuestType.PunchCardDelivery),
		"features": [
			"yellow roof",
			"two floors",
			"light is on",
			"looks like \"r\"",
			"slim",
		],
	},
	House.House4: {
		"name": House.House4,
		"quest": generate_quest(QuestType.PunchCardDelivery),
		"features": [
			"green roof",
			"two floors",
			"light is off",
			"looks like a rectangle",
		],
	},
	House.House5: {
		"name": House.House5,
		"quest": generate_quest(QuestType.PunchCardDelivery),
		"features": [
			"pink roof",
			"two floors",
			"light is off",
			"big window upfront",
			"looks like \"T\""
		],
	},
	House.House6: {
		"name": House.House6,
		"quest": generate_quest(QuestType.PunchCardDelivery),
		"features": [
			"blue roof",
			"three floors",
			"light is off",
			"tall",
			"slim",
		],
	},
	House.House7: {
		"name": House.House7,
		"quest": generate_quest(QuestType.PunchCardDelivery),
		"features": [
			"two floors",
			"black roof",
			"light is off",
			"canopy over the front door",
		],
	},
	House.House8: {
		"name": House.House8,
		"quest": generate_quest(QuestType.PunchCardDelivery),
		"features": [
			"light is off",
			"brown roof",
			"two floors",
			"big canopy over the front door",
		],
	},
}


