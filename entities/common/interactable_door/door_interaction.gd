extends StaticBody3D

enum DoorType {
	DOCTOR,
	VILLAGER
}

@onready var response_sound: AudioStreamPlayer3D = $ResponseSound

@export var door_type: DoorType = DoorType.VILLAGER
@export var house_name: Quests.House = Quests.House.OTHER


func _on_interactable_interacted(_body):
	var current_house = Quests.get_current_house()
	if door_type == DoorType.VILLAGER:
		response_sound.play()
	if !current_house:
		match door_type:
			DoorType.DOCTOR:
				UI.message.emit("doc", "easy, little one, you can rest now", 5)
			DoorType.VILLAGER:
				UI.message.emit("villager", "sorry, little one, i do not ask for anything from doc, thy different houses", 5)
		return
	match current_house["quest"]["sub_type"]:
		Quests.QuestType.PunchCardDelivery:
			UI.hint.emit("deliver card to the house")
			match door_type:
				DoorType.DOCTOR:
					var hint_index = randi_range(0, len(current_house["features"]) - 1)
					var hint1 = current_house["features"][hint_index]
					var hint2 = current_house["features"][(hint_index + 1) % len(current_house["features"])]
					UI.message.emit("doc", "deliver this package to " + hint1 + ", " + hint2 + " house", 5)
				DoorType.VILLAGER:
					if house_name != current_house["name"]:
						UI.message.emit("villager", "sorry, little one, i do not ask for anything from doc, thy different houses", 5)
						return
					UI.show_card.emit()
					Quests.current_quest_part_completed()
		Quests.QuestType.PunchCard:
			match door_type:
				DoorType.DOCTOR:
					var hint_index = randi_range(0, len(current_house["features"]) - 1)
					var hint1 = current_house["features"][hint_index]
					var hint2 = current_house["features"][(hint_index + 1) % len(current_house["features"])]
					var sicks = ""
					for key in current_house["quest"]["value"].keys():
						sicks += Quests.sick_name[key] + ", "
					UI.message.emit("doc", "oh i see, " + sicks + "deliver this medicine back to " + hint1 + ", " + hint2 + " house", 5)
					Quests.current_quest_part_completed()
				DoorType.VILLAGER:
					if house_name != current_house["name"]:
						UI.message.emit("villager", "sorry, little one, i do not ask for anything from doc, thy different houses", 5)
						return
					UI.message.emit("villager", "deliver this card to doc as soon as posible, little one", 5)
		Quests.QuestType.Delivery:
			match door_type:
				DoorType.DOCTOR:
					var hint_index = randi_range(0, len(current_house["features"]) - 1)
					var hint1 = current_house["features"][hint_index]
					var hint2 = current_house["features"][(hint_index + 1) % len(current_house["features"])]
					var sicks = ""
					for key in current_house["quest"]["value"].keys():
						sicks += Quests.sick_name[key] + ", "
					UI.message.emit("doc", "deliver medicine back to " + hint1 + ", " + hint2 + " house", 5)
				DoorType.VILLAGER:
					if house_name != current_house["name"]:
						UI.message.emit("villager", "sorry, little one, i do not ask for anything from doc, thy different houses", 5)
						return
					Quests.current_quest_part_completed()
					UI.message.emit("villager", "thank you, little one! i'll come to doc by the end of a day to pay him back", 5)
			
