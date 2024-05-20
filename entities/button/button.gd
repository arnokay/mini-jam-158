extends StaticBody3D

@onready var outline: MeshInstance3D = $Visual/outline

func _on_interactable_interacted(_body: Node):
	Inventory.add_item(Inventory.Item.Healing)
