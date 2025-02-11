class_name CharacterJump
extends PlayerState

func enter_state() -> void:
	print("Entering Jump State")

func state_process(delta: float) -> void:
	# Check if the player presses 'player_switch_bubble' while in mid-air.
	if Input.is_action_just_pressed("player_switch_bubble"):
		emit_signal("transitioned", self, "BubbleState")
		return  # Exit early for transition
		
	# Check for jump press
	character.buffer_jump_press()

func state_physics_process(delta: float) -> void:
	# Keeping jump buffering
	character.update_jump_buffer(delta)
	character.apply_gravity(delta)

	# Accel / Decel air control
	var dir = character.get_input_direction()
	character.update_horizontal_velocity(delta, dir)

	character.move_character(delta)

	# If landed, pick Idle vs Move
	if character.is_on_floor():
		# (Optional) Reset y velocity to 0 so there's no leftover downward velocity
		character.velocity.y = 0

		if dir.length() > 0.1:
			emit_signal("transitioned", self, "CharacterMove")
		else:
			emit_signal("transitioned", self, "CharacterIdle")
			
