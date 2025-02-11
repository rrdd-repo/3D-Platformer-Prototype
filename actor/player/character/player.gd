class_name Player
extends CharacterBody3D

#region Physics Variables
@export_category("Movement Physics")
@export var max_speed: float = 8.0
@export var rotation_speed: float = 4.0

# Acceleration
@export var ground_acceleration: float = 15.0
@export var ground_deceleration: float = 20.0
@export var air_acceleration: float = 8.0
@export var air_deceleration: float = 10.0
#endregion

#region Jump Variables
@export_category("Jump Physics")
@export var jump_speed: float = 10.0
@export var gravity: float = 12.0

@export var coyote_time: float = 0.2
@export var jump_buffer_time: float = 0.2

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
#endregion


#region Directions
func get_input_direction() -> Vector3:
	
	var input_dir: Vector2 = Input.get_vector("player_move_left", "player_move_right", "player_move_back", "player_move_forward")

	# Define 'forward' and 'right' as actual 3D vectors
	var forward = Vector3(0, 0, -1)
	var right = Vector3(1, 0, 0)
	
	# Combine the 2D input with the 3D vectors
	var move_direction: Vector3 = (forward * input_dir.y) + (right * input_dir.x)
	return move_direction.normalized()

func apply_gravity(delta: float) -> void:
	velocity.y -= gravity * delta
	
func rotate_character(delta: float, input_dir: Vector3) -> void:
	if input_dir.length() > 0.01:
		# Calculate the target rotation angle based on input direction
		var target_rotation = atan2(input_dir.x, input_dir.z)
		
		# Smoothly interpolate the current rotation towards the target rotation
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
#endregion
	
#region Jump
func update_coyote_time(delta: float) -> void:
	# If on floor, refresh coyote_timer
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0, coyote_timer - delta)
		
func update_jump_buffer(delta: float) -> void:
	# Decrease any existing buffer
	if jump_buffer_timer > 0:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)
		
func buffer_jump_press() -> void:
	# Called when player presses jump
	if Input.is_action_just_pressed("player_jump"):
		jump_buffer_timer = jump_buffer_time
	
func attempt_jump() -> bool:
	# We can jump if we have coyote time left OR we are on the floor,
	# AND we have a buffered jump or user pressed jump recently
	if (coyote_timer > 0 or is_on_floor()) and jump_buffer_timer > 0:
		velocity.y = jump_speed
		jump_buffer_timer = 0
		coyote_timer = 0
		return true
	return false
#endregion

#region Acceleration
func update_horizontal_velocity(delta: float, input_dir: Vector3) -> void:
	# We'll only modify x/z (horizontal) and keep current velocity.y for gravity/jump.
	# Current horizontal speed:
	var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
	var target_speed = input_dir * max_speed

	# Choose ground or air values based on whether we're on the floor
	var current_accel = ground_acceleration if is_on_floor() else air_acceleration
	var current_decel = ground_deceleration if is_on_floor() else air_deceleration

	if input_dir.length() > 0.01:
		# Accelerate toward target_speed
		horizontal_vel = horizontal_vel.lerp(target_speed, current_accel * delta)
	else:
		# Decelerate (come to a stop if no input)
		horizontal_vel = horizontal_vel.lerp(Vector3.ZERO, current_decel * delta)

	velocity.x = horizontal_vel.x
	velocity.z = horizontal_vel.z
#endregion

func move_character(delta: float) -> void:
	move_and_slide()
