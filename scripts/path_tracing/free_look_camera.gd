extends Node

@export var camera: Camera3D
@export var path_tracing: PathTracing

@export var mouse_sensitivity : float = 0.3
@export var move_speed : float = 0.3


func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("RMB"):
			camera.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			camera.rotate_object_local(Vector3(1.0, 0.0, 0.0), -deg_to_rad(event.relative.y * mouse_sensitivity))
			path_tracing.clear_samples()


func _process(_delta):
	if Input.is_action_pressed("RMB"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	_move()


func _move():
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	if input_vector.length() > 0.0: path_tracing.clear_samples()
	
	var displacement := Vector3.ZERO
	displacement = camera.global_transform.basis.z * move_speed * input_vector.y
	camera.global_transform.origin += displacement
	
	displacement = camera.global_transform.basis.x * move_speed * input_vector.x
	camera.global_transform.origin += displacement
