extends RayCast3D

var character
var last_interactable: Interactable

# Called when the node enters the scene tree for the first time.
func _ready():
	character = owner.get_node("%Character")
	add_exception(character)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if last_interactable:
		last_interactable.exited(character)
		last_interactable = null
	if is_colliding():
		var detected = get_collider()
		if detected.get_meta("is_interactable", false):
			var interactable: Interactable = detected.get_meta("interactable")
			last_interactable = interactable
			interactable.entered(character)
			if Input.is_action_just_pressed("interact"):
				interactable.interact(character)
