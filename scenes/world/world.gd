extends Node3D

func _ready():
	UI.message.emit("dev", "Hello! You are a bird who helps the local doctor deliver medicine to the villagers.\nTo complete the first task, interact with the door of the house behind you.", 10)
