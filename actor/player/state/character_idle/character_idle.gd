class_name CharacterIdle
extends PlayerState

func enter_state() -> void:
	print("Entering Idle State")

func state_process(delta: float) -> void:
	# Handle jump buffering
	character.buffer_jump_press()
		
	# If jump can happen, transition to Jump state
	if character.attempt_jump():
		emit_signal("transitioned", self, "CharacterJump")
		return
		
	# Movement check
	if character.get_input_direction().length() > 0.1:
		emit_signal("transitioned", self, "CharacterMove")

func state_physics_process(delta: float) -> void:
	
	# Coyote, jump buffer, gravity
	character.update_coyote_time(delta)
	character.update_jump_buffer(delta)
	character.apply_gravity(delta)
	
	var dir = Vector3.ZERO
	character.update_horizontal_velocity(delta, dir)
	
	character.move_character(delta)
