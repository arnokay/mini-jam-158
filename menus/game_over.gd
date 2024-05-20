extends Control

@onready var background: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var timer: Timer = $Timer

var showed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	background.visible = false
	label.visible = false
	Quests.game_over.connect(_on_game_ower)

func _on_game_ower():
	if !showed:
		showed = true
		background.visible = true
		label.visible = true
		timer.start()

func _on_timer_timeout():
	background.visible = false
	label.visible = false
