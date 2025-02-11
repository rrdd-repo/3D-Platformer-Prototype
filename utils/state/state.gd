class_name State
extends Node

signal transitioned(state: State, new_state_name: String)

func enter_state() -> void:
	pass
	
func exit_state() -> void:
	pass
	
func state_process(delta: float) -> void:
	pass
	
func state_physics_process(delta: float) -> void:
	pass
