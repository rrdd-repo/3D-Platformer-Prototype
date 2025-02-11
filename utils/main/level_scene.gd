class_name LevelScene
extends Node3D

@export var initial_scene: PackedScene
var current_scene: Node3D

func _ready() -> void:
	load_initial_scene()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		reset_scene()
		
func load_initial_scene() -> void:
	if initial_scene:
		current_scene = initial_scene.instantiate()
		add_child(current_scene)
	else:
		push_error("Initial scene is not assigned.")
		
func reset_scene() -> void:
	if current_scene:
		remove_child(current_scene)
		current_scene.queue_free()
	load_initial_scene()
