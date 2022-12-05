extends Panel

@export var path_tracing: PathTracing
@export var slider: Slider
@export var label: Label


func _ready() -> void:
	slider.drag_ended.connect(_on_drag_ended)
	slider.value_changed.connect(_on_value_changed)
	slider.value = path_tracing.ray_depth


func _on_value_changed(value: float) -> void:
	set_text(value)


func _on_drag_ended(changed: bool) -> void:
	if not changed: return
	path_tracing.ray_depth = slider.value
	path_tracing.clear_samples()
	slider.release_focus()


func set_text(value: int) -> void:
	label.text = "Ray depth: %d" % value
