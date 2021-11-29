extends Node3D

# Tutorial link: https://github.com/godotengine/godot-docs/issues/4834

# Export vars
@export_file var shader_comp
@export_node_path var texture_holder

# Internal vars
@onready var r_device: RenderingDevice = RenderingServer.create_local_rendering_device()
@onready var width = get_viewport().size.x
@onready var height = get_viewport().size.y


func _ready():
	print("Rendering " + str(width) + "x" + str(height))
	var msec = Time.get_ticks_msec()
	var cp = ComputePipeline.new(r_device, shader_comp)
	if (not r_device.compute_pipeline_is_valid(cp.rid)): return
	
	compute_list_process(cp)
	print("Done in " + str(Time.get_ticks_msec() - msec) + "msec")

func compute_list_process(cp: ComputePipeline):
	# Create buffer
	var pba = PackedByteArray()
	var size = width * height * 16		# 4 channels (rgba) 4 bytes each
	pba.resize(size)
	var buffer_rid = r_device.storage_buffer_create(size, pba)
	
	# Create uniform_set
	var uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(buffer_rid)
	var unifrom_set_rid = r_device.uniform_set_create([uniform], cp.shader_rid, 0)
	
	# Run compute list
	var c_list = r_device.compute_list_begin()
	r_device.compute_list_bind_compute_pipeline(c_list, cp.rid)
	r_device.compute_list_bind_uniform_set(c_list, unifrom_set_rid, 0)
	r_device.compute_list_dispatch(c_list, width, height, 1)
	r_device.compute_list_end()
#	r_device.compute_list_add_barrier(c_list)
	r_device.submit()
	r_device.sync()
	
	# Get data from buffer and create image
	var byte_data = r_device.buffer_get_data(buffer_rid)
	set_image(create_image(byte_data))


func create_image(data: PackedByteArray) -> Image:
	var image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGBAF, data)
	return image

func set_image(image: Image):
	var new_texture = ImageTexture.new()
	new_texture.create_from_image(image)
	get_node(texture_holder).texture = new_texture
