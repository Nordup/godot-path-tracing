extends Control

@export_node_path var path_tracing_node
@onready var path_tracing = get_node(path_tracing_node) as PathTracing


func _input(_event) -> void:
	if Input.is_action_just_pressed("ui_exit"):
		get_tree().quit()


func _on_RenderButton_up() -> void:
	path_tracing.render_to_image()
