class_name CharacterMove
extends PlayerState

func enter_state() -> void:
	print("Entering Move State")

func state_process(delta: float) -> void:
	# Handle jump buffering
	character.buffer_jump_press()
		
	# If jump can happen, transition to Jump state
	if character.attempt_jump():
		emit_signal("transitioned", self, "CharacterJump")
		return
	
	# If no movement input, go idle
	if character.get_input_direction().length() < 0.1:
		emit_signal("transitioned", self, "CharacterIdle")

func state_physics_process(delta: float) -> void:
	
	# Timers, gravity
	character.update_coyote_time(delta)
	character.update_jump_buffer(delta)
	character.apply_gravity(delta)

	# Acceleration/deceleration
	var dir = character.get_input_direction()
	character.update_horizontal_velocity(delta, dir)
	
	character.rotate_character(delta, dir)

	# Move
	character.move_character(delta)
