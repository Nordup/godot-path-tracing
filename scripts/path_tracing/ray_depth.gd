extends Panel

@export var path_tracing: PathTracing
@export var slider: Slider
@export var label: Label


func _ready() -> void:
	slider.value_changed.connect(_on_value_changed)
	slider.value = path_tracing.ray_depth


func _on_value_changed(value) -> void:
	path_tracing.ray_depth = value
	path_tracing.clear_samples()
	slider.release_focus()
	set_text(value)


func set_text(value) -> void:
	label.text = "Ray depth: %d" % value
