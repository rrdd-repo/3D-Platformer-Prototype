class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary[String, State] = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_upper()] = child
			child.transitioned.connect(on_child_transition)
			
	if initial_state:
		current_state = initial_state
		current_state.enter_state()

func _process(delta: float) -> void:
	if current_state:
		current_state.state_process(delta)
		
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.state_physics_process(delta)

func on_child_transition(state: State, new_state_name: String) -> void:
	if(state != current_state):
		return
		
	var new_state = states.get(new_state_name.to_upper())
	if !new_state:
		return
		
	# Clean up the previous state
	if current_state:
		current_state.exit_state()
		
	# Intialize the new state
	new_state.enter_state()
	current_state = new_state
