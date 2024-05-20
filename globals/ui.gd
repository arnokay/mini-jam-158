extends Node

signal message(who: String, text: String, duration: float)
signal show_card
signal hint(text: String)

func _input(event):
	if event.is_action_pressed("mouse_lock"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("mouse_unlock"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
