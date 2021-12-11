extends Control

@export_node_path var path_tracing_node
@export_node_path var button_node

@onready var path_tracing = get_node(path_tracing_node) as PathTracing
@onready var button = get_node(button_node) as Button


func _input(_event) -> void:
	if Input.is_action_just_pressed("ui_exit"):
		get_tree().quit()


func _on_RenderButton_up() -> void:
	path_tracing.render()
