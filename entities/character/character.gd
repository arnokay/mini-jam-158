extends CharacterBody3D

@onready var phantom_camera: PhantomCamera3D
@onready var camera: Camera3D
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var ground_check: RayCast3D = $RayCast3D
@onready var wings_sound: AudioStreamPlayer3D = $WingsSound

@onready var player_visual: Node3D = $RootNode

@export var SPEED = 2.0
@export var JUMP_VELOCITY = 3.5

var disabled: bool = false

@export var mouse_sensitivity: float = 0.05
@export var gamepad_sensitivity := 0.075

# camera values
#TODO: find out for what
@export var min_pitch: float = -89.9
@export var max_pitch: float = 50
@export var min_yaw: float = 0
@export var max_yaw: float = 360

var direction: Vector3

var movement_velocity: Vector3

# for visual interpolation
var _physics_body_trans_last: Transform3D
var _physics_body_trans_current: Transform3D

var mouse_captured: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var rotation_target: Vector3
var input_mouse: Vector2
var last_camera_rotation: float = 0

var anim_blend_walk_val: float = 0
var anim_blend_flying_val: float = 0
var anim_blend_flying_left_val: float = 0
var anim_blend_flying_right_val: float = 0
var anim_blend_flap_val: float = 0
var anim_oneshot_jump_val: bool = false
var anim_oneshot_swoop_val: bool = false
var anim_oneshot_swoop_stop_val: bool = false

@export var anim_speed: float = 10

enum CURRENT_ANIM {
	WALK,
	FLYING,
	FLYING_LEFT,
	FLYING_RIGHT,
	IDLE,
}

var current_anim = CURRENT_ANIM.IDLE

func update_anim_tree():
	anim_tree["parameters/Walk/blend_amount"] = anim_blend_walk_val
	anim_tree["parameters/Flying/blend_amount"] = anim_blend_flying_val
	anim_tree["parameters/Flap/blend_amount"] = anim_blend_flap_val
	anim_tree["parameters/Left/blend_amount"] = anim_blend_flying_left_val
	anim_tree["parameters/Right/blend_amount"] = anim_blend_flying_right_val
	if anim_oneshot_jump_val:
		anim_tree["parameters/Jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		anim_oneshot_jump_val = false
	if anim_oneshot_swoop_val:
		anim_tree["parameters/Swoop/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		anim_oneshot_swoop_val = false
	if anim_oneshot_swoop_stop_val:
		anim_tree["parameters/Swoop/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
		anim_oneshot_swoop_stop_val = false

func handle_animations(delta: float):
	match current_anim:
		CURRENT_ANIM.IDLE:
			anim_blend_walk_val = lerpf(anim_blend_walk_val, 0, delta * anim_speed)
			anim_blend_flying_val = lerpf(anim_blend_flying_val, 0, delta * anim_speed)
			anim_blend_flap_val = lerpf(anim_blend_flap_val, 0, delta * anim_speed)
			anim_blend_flying_left_val = lerpf(anim_blend_flying_left_val, 0, delta * anim_speed)
			anim_blend_flying_right_val = lerpf(anim_blend_flying_right_val, 0, delta * anim_speed)
		CURRENT_ANIM.WALK:
			anim_blend_walk_val = lerpf(anim_blend_walk_val, 1, delta * anim_speed)
			anim_blend_flying_val = lerpf(anim_blend_flying_val, 0, delta * anim_speed)
			anim_blend_flap_val = lerpf(anim_blend_flap_val, 0, delta * anim_speed)
			anim_blend_flying_left_val = lerpf(anim_blend_flying_left_val, 0, delta * anim_speed)
			anim_blend_flying_right_val = lerpf(anim_blend_flying_right_val, 0, delta * anim_speed)
		CURRENT_ANIM.FLYING:
			anim_blend_walk_val = lerpf(anim_blend_walk_val, 0, delta * anim_speed)
			anim_blend_flying_val = lerpf(anim_blend_flying_val, 1, delta * anim_speed)
			anim_blend_flap_val = lerpf(anim_blend_flap_val, 0, delta * anim_speed)
			anim_blend_flying_left_val = lerpf(anim_blend_flying_left_val, 0, delta * anim_speed)
			anim_blend_flying_right_val = lerpf(anim_blend_flying_right_val, 0, delta * anim_speed)
		CURRENT_ANIM.FLYING_LEFT:
			anim_blend_walk_val = lerpf(anim_blend_walk_val, 0, delta * anim_speed)
			anim_blend_flying_val = lerpf(anim_blend_flying_val, 0, delta * anim_speed)
			anim_blend_flap_val = lerpf(anim_blend_flap_val, 0, delta * anim_speed)
			anim_blend_flying_left_val = lerpf(anim_blend_flying_left_val, 1, delta * anim_speed)
			anim_blend_flying_right_val = lerpf(anim_blend_flying_right_val, 0, delta * anim_speed)
		CURRENT_ANIM.FLYING_RIGHT:
			anim_blend_walk_val = lerpf(anim_blend_walk_val, 0, delta * anim_speed)
			anim_blend_flying_val = lerpf(anim_blend_flying_val, 0, delta * anim_speed)
			anim_blend_flap_val = lerpf(anim_blend_flap_val, 0, delta * anim_speed)
			anim_blend_flying_left_val = lerpf(anim_blend_flying_left_val, 0, delta * anim_speed)
			anim_blend_flying_right_val = lerpf(anim_blend_flying_right_val, 1, delta * anim_speed)
	update_anim_tree()

func _ready():
	phantom_camera = owner.get_node("%PlayerCamera")
	camera = owner.get_node("%MainCamera")
	if phantom_camera.get_follow_mode() == phantom_camera.FollowMode.THIRD_PERSON:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and is_instance_valid(phantom_camera) and !disabled and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_set_pcam_rotation(phantom_camera, event)

func _process(delta: float) -> void:
	player_visual.global_transform = _physics_body_trans_last.interpolate_with(
		_physics_body_trans_current,
		Engine.get_physics_interpolation_fraction()
	)
	player_visual.scale = Vector3(30, 30, 30)
	if direction:
		player_visual.rotation.y = camera.rotation.y
		last_camera_rotation = camera.rotation.y
	else:
		player_visual.rotation.y = last_camera_rotation
	

func _physics_process(delta):
	_physics_body_trans_last = _physics_body_trans_current
	_physics_body_trans_current = global_transform

	handle_controls(delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		anim_oneshot_jump_val = true
		wings_sound.playing = true

	if not is_on_floor() and not ground_check.is_colliding() and Input.is_action_just_pressed("swoop"):
		anim_oneshot_swoop_val = true

	if ground_check.is_colliding():
		anim_oneshot_swoop_stop_val = true

	 #Add the gravity.
	if not is_on_floor():
		if ground_check.is_colliding():
			velocity.y -= gravity * delta
		else:
			if direction:
				velocity.y -= (gravity * 0.2) * delta
			else:
				velocity.y -= (gravity * 0.5) * delta

	if direction and !ground_check.is_colliding() and Input.is_action_pressed("speed_up"):
		camera.fov = lerpf(camera.fov, 55, delta * 10)
	else:
		camera.fov = lerpf(camera.fov, 75, delta * 10)

	if direction:
		current_anim = CURRENT_ANIM.WALK
		var move_dir: Vector3 = Vector3.ZERO
		move_dir.x = direction.x
		move_dir.z = direction.z

		move_dir = move_dir.rotated(Vector3.UP, camera.rotation.y).normalized()
		
		if is_on_floor():
			velocity.x = move_dir.x * SPEED
			velocity.z = move_dir.z * SPEED
		else:
			if Input.is_action_pressed("speed_up"):
				velocity.x = lerpf(velocity.x, move_dir.x * (SPEED * 4), delta)
				velocity.z = lerpf(velocity.z, move_dir.z * (SPEED * 4), delta)
			else:
				velocity.x = lerpf(velocity.x, move_dir.x * (SPEED * 2), delta)
				velocity.z = lerpf(velocity.z, move_dir.z * (SPEED * 2), delta)
	else:
		current_anim = CURRENT_ANIM.IDLE
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if not is_on_floor():
		current_anim = CURRENT_ANIM.FLYING
		if direction.x < 0:
			current_anim = CURRENT_ANIM.FLYING_LEFT
		if direction.x > 0: 
			current_anim = CURRENT_ANIM.FLYING_RIGHT
	
	handle_animations(delta)
	
	
	
	move_and_slide()

func handle_controls(_delta):
	# Movement
	
	var input := Input.get_vector("left", "right", "forward", "back")
	
	direction = Vector3(input.x, 0, input.y).normalized()
	

func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3

		# Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()

		# Change the X rotation
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity

		# Clamp the rotation in the X axis so it go over or under the target
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)

		# Change the Y rotation value
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity

		# Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)

		# Change the SpringArm3D node's rotation and rotate around its target
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
