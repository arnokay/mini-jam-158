class_name Interactable
extends Node3D

signal interacted(body: Node)
signal on_enter(body: Node)
signal on_exit(body: Node)

var outline: Node3D

func _ready():
	var parent = get_parent()
	outline = parent.find_child("outline")
	if is_instance_valid(outline):
		outline.visible = false
	parent.set_meta("is_interactable", true)
	parent.set_meta("interactable", self)

func entered(body: Node):
	if is_instance_valid(outline):
		outline.visible = true
	on_enter.emit(body)

func exited(body: Node):
	if is_instance_valid(outline):
		outline.visible = false
	on_exit.emit(body)

func interact(body: Node):
	interacted.emit(body)
