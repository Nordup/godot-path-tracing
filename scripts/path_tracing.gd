extends Node

# Export vars
@export_file var comp_shader
@export_node_path var texture_holder

# Internal vars
@onready var width = get_viewport().size.x
@onready var height = get_viewport().size.y


func _ready():
	if comp_shader == null:
		push_error("Compute shader path is not set")
		return
	
	var c_shader = FileTools.get_file_text(comp_shader)
	var r_pipeline = RenderingPipeline.new(width, height, c_shader)
#	var uniform_array = [RDUniform.new()]
#	r_pipeline.set_uniforms(uniform_array)
	
	print("Rendering " + str(width) + "x" + str(height))
	var msec = Time.get_ticks_msec()
	var image = r_pipeline.render()
	print("Done in " + str(Time.get_ticks_msec() - msec) + "msec")

	if image == null:
		push_warning("Something went wrong! Check for errors")
		return
	set_image(image)


func set_image(image: Image):
	if image == null: return
	var new_texture = ImageTexture.new()
	new_texture.create_from_image(image)
	get_node(texture_holder).texture = new_texture
