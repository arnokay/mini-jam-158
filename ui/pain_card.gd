extends Control

@onready var card: TextureRect = $card
@onready var timer: Timer = $Timer

var sick_type_to_letter: Dictionary = {
	Quests.SickType.Abdominal: "s",
	Quests.SickType.Headache: "h",
	Quests.SickType.Joints: "j",
}

@onready var buttons: Dictionary = {
	"h1": $h1,
	"h2": $h2,
	"h3": $h3,
	"h4": $h4,
	"h5": $h5,
	"s1": $s1,
	"s2": $s2,
	"s3": $s3,
	"s4": $s4,
	"s5": $s5,
	"j1": $j1,
	"j2": $j2,
	"j3": $j3,
	"j4": $j4,
	"j5": $j5,
}

func _ready():
	for key in buttons.keys():
		buttons[key].visible = false
	card.visible = false
	UI.show_card.connect(_on_show_card)

func _on_show_card():
	var house = Quests.get_current_house()
	var value = house["quest"]["value"]
	for key in buttons.keys():
		buttons[key].visible = true
	for key in value.keys():
		var button_key = sick_type_to_letter[key] + str(value[key])
		buttons[button_key].visible = false
	card.visible = true
	timer.start()


func _on_timer_timeout():
	card.visible = false
	for key in buttons.keys():
		buttons[key].visible = false
