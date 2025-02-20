extends CharacterBody3D

enum MovementState {
	WALKING,
	SPRINTING,
	CROUCHING
}

@export_group("Enable features")
@export var ENABLE_JUMP: bool = true          # Enables/disables the ability to jump
@export var ENABLE_SPRINT: bool = true        # Enables/disables the ability to sprint (run faster)
@export var ENABLE_HEAD_BOB: bool = true      # Enables/disables camera bobbing while moving
@export var ENABLE_FOV_CHANGE: bool = true    # Enables/disables FOV changes while sprinting
@export var ENABLE_TILT: bool = true          # Enables/disables camera tilt when strafing
@export var ENABLE_CROUCH: bool = true        # Enables/disables the ability to crouch

@export_group("Movement")
@export var WALKING_SPEED: float = 5.0        # Base movement speed when walking
@export var SPRINTING_SPEED: float = 8.0      # Movement speed when sprinting
@export var MAX_AIR_SPEED: float = 12.0       # Maximum speed while in the air
@export var ACCELERATION: float = 15.0        # How quickly the player reaches max speed
@export var AIR_ACCELERATION: float = 3.0     # How quickly the player accelerates in air
@export var AIR_STRAFE_MULTIPLIER: float = 2.0 # How much stronger strafing is in the air
@export var GROUND_FRICTION: float = 7.0      # How quickly the player comes to a stop
@export var JUMP_VELOCITY: float = 4.8        # Initial velocity applied when jumping

@export_group("Mouse")
@export_range(0.0, 1.0, 0.01) var SENSITIVITY: float = 0.25  # Mouse sensitivity (0.0 to 1.0)

@export_group("Bob")
@export var BOB_FREQ: float = 2.4             # Frequency of head bobbing motion
@export var BOB_AMP: float = 0.08             # Amplitude (strength) of head bobbing motion
var t_bob: float = 0.0                        # Time accumulator for head bobw

@export_group("FOV")
@export var BASE_FOV: float = 73.0            # Default field of view in degrees
@export var FOV_CHANGE: float = 1.5           # How much FOV increases when sprinting

@export_group("Tilt")
@export var TILT_AMOUNT: float = 2.0          # Maximum camera tilt angle when strafing (degrees)
@export var TILT_SPEED: float = 4.0           # How fast the camera tilts
var current_tilt_velocity: float = 0.0        # Current velocity of camera tilt

@export_group("Crouch")
@export var STANDING_HEIGHT: float = 2.0      # Player's collision height when standing
@export var CROUCH_HEIGHT: float = 1.5        # Player's collision height when crouching
@export var CROUCH_TRANSITION_SPEED: float = 10.0  # How fast to transition between standing/crouching
@export var CROUCH_SPEED: float = 3.0         # Movement speed when crouching

var gravity: float = 9.8
var current_state: MovementState = MovementState.WALKING
var speed: float = WALKING_SPEED

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var mouse_motion: Vector2 = Vector2.ZERO
var input_dir: Vector2 = Vector2.ZERO
var current_height: float = STANDING_HEIGHT
var initial_head_offset: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initial_head_offset = STANDING_HEIGHT - head.position.y
	camera.rotation = Vector3.ZERO
	current_tilt_velocity = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_motion += event.relative


func _physics_process(delta: float) -> void:
	get_input()
	handle_mouse_movement()
	handle_gravity(delta)
	update_movement_state()
	
	if ENABLE_JUMP:
		handle_jump()
	if ENABLE_CROUCH:
		handle_crouch(delta)
	
	handle_movement(delta)
	
	if ENABLE_HEAD_BOB:
		handle_head_bob(delta)
	if ENABLE_FOV_CHANGE:
		handle_fov(delta)
	if ENABLE_TILT:
		handle_tilt(delta)
	
	move_and_slide()


func get_input() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")


func update_movement_state() -> void:
	if check_ceiling():
		current_state = MovementState.CROUCHING
		speed = CROUCH_SPEED
	elif Input.is_action_pressed("crouch") and is_on_floor():
		current_state = MovementState.CROUCHING
		speed = CROUCH_SPEED
	elif Input.is_action_pressed("sprint") and ENABLE_SPRINT:
		current_state = MovementState.SPRINTING
		speed = SPRINTING_SPEED
	else:
		current_state = MovementState.WALKING
		speed = WALKING_SPEED


func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func handle_movement(delta: float) -> void:
	var direction: Vector3 = get_movement_direction()
	
	if is_on_floor():
		apply_ground_movement(direction, delta)
	else:
		apply_air_movement(direction, delta)


func get_movement_direction() -> Vector3:
	return (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


func apply_ground_movement(direction: Vector3, delta: float) -> void:
	var target_velocity = direction * speed
	var current_horizontal = Vector3(velocity.x, 0, velocity.z)
	
	current_horizontal = current_horizontal.lerp(target_velocity, delta * ACCELERATION)
	
	if direction == Vector3.ZERO:
		current_horizontal = current_horizontal.lerp(Vector3.ZERO, delta * GROUND_FRICTION)
	
	velocity.x = current_horizontal.x
	velocity.z = current_horizontal.z


func apply_air_movement(direction: Vector3, delta: float) -> void:
	var target_velocity = direction * speed
	var current_horizontal = Vector3(velocity.x, 0, velocity.z)
	
	
	if direction != Vector3.ZERO:
		var current_in_direction = direction * current_horizontal.dot(direction)
		var current_perpendicular = current_horizontal - current_in_direction
		
		var target_in_direction = direction * target_velocity.dot(direction)
		
		var effective_acceleration = AIR_ACCELERATION
		if abs(input_dir.x) > 0:
			effective_acceleration *= AIR_STRAFE_MULTIPLIER
		
		current_in_direction = current_in_direction.lerp(target_in_direction, delta * effective_acceleration)
		
		current_horizontal = current_in_direction + current_perpendicular
	

	if current_horizontal.length() > MAX_AIR_SPEED:
		current_horizontal = current_horizontal.normalized() * MAX_AIR_SPEED
	
	velocity.x = current_horizontal.x
	velocity.z = current_horizontal.z


func handle_head_bob(delta: float) -> void:
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob) if ENABLE_HEAD_BOB else Vector3.ZERO


func handle_fov(delta: float) -> void:
	var target_fov: float = BASE_FOV
	if ENABLE_FOV_CHANGE and current_state == MovementState.SPRINTING:
		var velocity_clamped: float = clamp(velocity.length(), 0.0, SPRINTING_SPEED) / SPRINTING_SPEED
		target_fov += FOV_CHANGE * velocity_clamped
	
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func handle_mouse_movement() -> void:
	var sensitivity_multiplier = 0.002
	head.rotate_y(-mouse_motion.x * SENSITIVITY * sensitivity_multiplier)
	camera.rotate_x(-mouse_motion.y * SENSITIVITY * sensitivity_multiplier)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(70))
	mouse_motion = Vector2.ZERO


func handle_tilt(delta: float) -> void:
	if ENABLE_TILT:
		var target_tilt: float = -input_dir.x * deg_to_rad(TILT_AMOUNT)
		var tilt_acceleration: float = 8.0
		current_tilt_velocity = lerp(current_tilt_velocity, 
								   target_tilt - camera.rotation.z,
								   delta * tilt_acceleration)
		camera.rotation.z += current_tilt_velocity * delta * TILT_SPEED
	else:
		camera.rotation.z = lerp(camera.rotation.z, 0.0, delta * TILT_SPEED)
		current_tilt_velocity = 0.0


func handle_crouch(delta: float) -> void:
	var is_crouching: bool = current_state == MovementState.CROUCHING
	var target_height: float = CROUCH_HEIGHT if is_crouching else STANDING_HEIGHT
	current_height = lerp(current_height, target_height, delta * CROUCH_TRANSITION_SPEED)
	
	collision_shape.shape.height = current_height
	head.position.y = current_height - initial_head_offset


func check_ceiling() -> bool:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3(0, STANDING_HEIGHT + 0.1, 0),
		0xFFFFFFFF,
		[get_rid()]
	)
	var result: Dictionary = space_state.intersect_ray(params)
	return !result.is_empty()
