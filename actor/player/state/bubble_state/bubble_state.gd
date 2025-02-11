class_name BubbleState
extends PlayerState

@export_category("Movement")
@export var bounce_multiplier: float = 0.8
@export var influence_factor: float = 0.5

@export_category("Hit Window")
@export var bounce_input_time: float = 0.5
@export var bubble_hit_buffer_time: float = 0.2

@export_category("Aesthetics")
@export var animation_player: AnimationPlayer

var has_initial_bounce: bool = false
var waiting_for_bubble_hit: bool = false
var bubble_hit_timer: float = 0.0
var bubble_hit_buffer_timer: float = 0.0
var stored_collision_normal: Vector3 = Vector3.ZERO

func enter_state() -> void:
	print("Entering Bubble State")
	animation_player.play("bubble_switch")
	has_initial_bounce = false
	waiting_for_bubble_hit = false
	bubble_hit_timer = 0.0
	bubble_hit_buffer_timer = 0.0
	stored_collision_normal = Vector3.ZERO

func state_process(delta: float) -> void:
	# If the player presses "player_hit_bubble", start the buffer timer.
	if Input.is_action_just_pressed("player_hit_bubble"):
		bubble_hit_buffer_timer = bubble_hit_buffer_time
	# Decrease the buffer timer over time.
	elif bubble_hit_buffer_timer > 0:
		bubble_hit_buffer_timer = max(bubble_hit_buffer_timer - delta, 0)

func state_physics_process(delta: float) -> void:
	# Always apply gravity so the bubble doesn't fly forever.
	character.apply_gravity(delta)
	
	if waiting_for_bubble_hit:
		bubble_hit_timer -= delta
	
		# Calculate final bounce normal using the stored collision normal and player's input
		var final_bounce_normal: Vector3 = calculate_bounce_normal(stored_collision_normal)
		# If the player has buffered a bubble hit (or presses it now), perform the bounce.
		if bubble_hit_buffer_timer > 0:
			waiting_for_bubble_hit = false
			bubble_hit_timer = 0.0
			bubble_hit_buffer_timer = 0.0  # Clear the buffered input
			character.velocity = character.velocity.bounce(final_bounce_normal) * bounce_multiplier
			stored_collision_normal = Vector3.ZERO
		elif bubble_hit_timer <= 0:
			animation_player.play("character_switch")
			# If the player failed to press the button within the allowed time, exit bubble state.
			emit_signal("transitioned", self, "CharacterIdle")
			return
	else:
		# Detect collisions using move_and_collide().
		var collision = character.move_and_collide(character.velocity * delta)
		if collision:
			if not has_initial_bounce:
				# For the first collision, also apply influence for debugging purposes.
				var final_bounce_normal: Vector3 = calculate_bounce_normal(collision.get_normal())
				character.velocity = character.velocity.bounce(final_bounce_normal) * bounce_multiplier
				has_initial_bounce = true
			else:
				# For subsequent collisions, start waiting for a bubble hit input.
				waiting_for_bubble_hit = true
				bubble_hit_timer = bounce_input_time
				stored_collision_normal = collision.get_normal()
				
# Helper function to calculate the final bounce normal using player's input
func calculate_bounce_normal(collision_normal: Vector3) -> Vector3:
	var input_dir: Vector3 = character.get_input_direction()
	if input_dir.length() > 0.1:
		return (collision_normal + input_dir * influence_factor).normalized()
	return collision_normal
