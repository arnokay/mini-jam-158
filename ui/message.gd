extends Control

@onready var main_label: Label = $MainText
@onready var who_label: Label = $Who
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	main_label.text = ""
	who_label.text = ""
	self.visible = false
	UI.message.connect(_on_message)

func _on_message(who: String, text: String, duration: float):
	who_label.text = who
	main_label.text = text
	self.visible = true
	timer.wait_time = duration
	timer.start()


func _on_timer_timeout():
	self.visible = false
	main_label.text = ""
	who_label.text = ""
