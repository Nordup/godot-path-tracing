extends Node
class_name PathTracing

# Export vars
@export_file var comp_shader
@export_node_path var texture_holder

# Internal vars
@onready var width = get_viewport().size.x
@onready var height = get_viewport().size.y
var r_pipeline: RenderingPipeline


func _ready() -> void:
	# await scene initialization
	await get_tree().create_timer(1).timeout
	
	if comp_shader == null:
		push_error("Compute shader path is not set")
		return
	
	var c_shader = FileTools.get_file_text(comp_shader)
	r_pipeline = RenderingPipeline.new(width, height, c_shader)
	render_to_image()


func render_to_image() -> void:
	if r_pipeline == null:
		push_error("RenderingPipeline is not Initialized")
		return
	
	print("\nRendering " + str(width) + "x" + str(height))
	var msec = Time.get_ticks_msec()
	set_objects_uniforms()
	var image = r_pipeline.render()

	if image == null:
		push_warning("Something went wrong! Check for errors")
		return
	set_image(image)
	print("Done in " + str(Time.get_ticks_msec() - msec) + "msec")


func set_objects_uniforms() -> void:
	var uniform_array = []
	var camera_uniform = SceneCollector.camera_uniform(r_pipeline.r_device, 0)
	var sphere_buffer_uniform = SceneCollector.sphere_buffer_uniform(r_pipeline.r_device, 1)
	uniform_array.append(camera_uniform)
	uniform_array.append(sphere_buffer_uniform)
	r_pipeline.set_uniforms(uniform_array)


func set_image(image: Image) -> void:
	if image == null: return
	var new_texture = ImageTexture.new()
	new_texture.create_from_image(image)
	get_node(texture_holder).texture = new_texture
