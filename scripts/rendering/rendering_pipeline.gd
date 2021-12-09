extends RefCounted
class_name RenderingPipeline

var width: int
var height: int

var r_device: RenderingDevice
var c_pipeline: ComputePipeline

var render_buffer: RID
var rb_uniform: RDUniform
var rb_unifrom_set: RID

var uniform_array # Array[RDUniform]
var uniform_array_set: RID


func _init(_width: int, _height: int, c_shader: String) -> void:
	width = _width
	height = _height
	r_device = RenderingServer.create_local_rendering_device()
	c_pipeline = ComputePipeline.new(r_device, c_shader)
	create_render_buffer()
	print("Compute pipeline valid: " + str(r_device.compute_pipeline_is_valid(c_pipeline.rid)))


func create_render_buffer() -> void:
	# Buffer
	var pba = PackedByteArray()
	var size = width * height * 16		# 4 channels (rgba) 4 bytes each
	pba.resize(size)
	render_buffer = r_device.storage_buffer_create(size, pba)
	
	# Uniform
	rb_uniform = RDUniform.new()
	rb_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	rb_uniform.binding = 0
	rb_uniform.add_id(render_buffer)
	
	# Uniform set
	rb_unifrom_set = r_device.uniform_set_create([rb_uniform], c_pipeline.shader_rid, 0)


func set_uniforms(uniforms) -> void:
	uniforms = uniforms as Array[RDUniform]
	if uniforms.size() < 1:
		push_error("Cannot set_uniform: Empty RDUniform array")
		return
	
	# Uniform and uniform set
	uniform_array = uniforms
	uniform_array_set = r_device.uniform_set_create(uniform_array, c_pipeline.shader_rid, 1)


func render() -> Image:
	var data = compute_list_process()
	if data == PackedByteArray(): return null

	var image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGBAF, data)
	return image


func compute_list_process() -> PackedByteArray:
	if (not r_device.compute_pipeline_is_valid(c_pipeline.rid) ||
		r_device == null): return PackedByteArray()
	
	# Run compute list
	var c_list = r_device.compute_list_begin()
	r_device.compute_list_bind_uniform_set(c_list, rb_unifrom_set, 0)
	if r_device.uniform_set_is_valid(uniform_array_set):
		r_device.compute_list_bind_uniform_set(c_list, uniform_array_set, 1)
	r_device.compute_list_bind_compute_pipeline(c_list, c_pipeline.rid)
	r_device.compute_list_dispatch(c_list, width, height, 1)
	r_device.compute_list_end()
	r_device.submit()
	r_device.sync()
	
	# Data from buffer
	var data = r_device.buffer_get_data(render_buffer)
	return data
