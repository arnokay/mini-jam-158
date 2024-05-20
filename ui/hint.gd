extends Control

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = ""
	UI.hint.connect(_on_hint)

func _on_hint(text: String):
	var current_house = Quests.current_house
	var house_hints = ""
	if current_house:
		var hint_index = randi_range(0, len(current_house["features"]) - 1)
		var hint1 = current_house["features"][hint_index]
		var hint2 = current_house["features"][(hint_index + 1) % len(current_house["features"])]
		var hint3 = current_house["features"][(hint_index + 2) % len(current_house["features"])]
		house_hints += "house hints:\n" + hint1 + "\n" + hint2 + "\n" + hint3
	label.text = "hint: " + text + "\n" + house_hints
