extends Node

@export var debug_mode: DebugTools.DebugMode
@export var path_tracing: PathTracing


func _ready() -> void:
	DebugTools.set_mode(debug_mode)
	var c_pipeline_is_valid = path_tracing.compute.r_device.compute_pipeline_is_valid(
		path_tracing.compute.pipeline_rid
	)
	DebugTools.print_quiet("Compute pipeline valid: " + str(c_pipeline_is_valid))
	DebugTools.print_quiet("Rendering " + str(path_tracing.width) + "x" + str(path_tracing.height))
	path_tracing.rendered.connect(_on_rendered)


func _on_rendered(_texture: Texture, render_time: int) -> void:
	DebugTools.print_quiet("\nRendered in " + str(render_time) + " msec")
	
	# Print debug buffer data
	DebugTools.print_full("Debug buffer:")
	var float_pba = path_tracing.compute.r_device.buffer_get_data(path_tracing.debug_buffer.rid)
	DebugTools.print_debug_buffer_full(float_pba)
