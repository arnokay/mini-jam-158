extends Control

@onready var label: Label = $Label

func _process(_delta):
	var labelValue: String = ""
	for key in Inventory.get_items():
		var item = Inventory.get_item(key)
		labelValue += "[" + item[Inventory.NAME] +"]: " + str(item[Inventory.AMOUNT]) + "\n"
	label.text = labelValue
