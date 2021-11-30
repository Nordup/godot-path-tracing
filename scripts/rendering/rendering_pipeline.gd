extends RefCounted
class_name RenderingPipeline

# Tutorial link: https://github.com/godotengine/godot-docs/issues/4834

var width: int
var height: int

var r_device: RenderingDevice
var c_pipeline: ComputePipeline


func _init(_width: int, _height: int, c_shader: String):
	width = _width
	height = _height
	r_device = RenderingServer.create_local_rendering_device()
	c_pipeline = ComputePipeline.new(r_device, c_shader)
	print("Compute pipeline valid: " + str(r_device.compute_pipeline_is_valid(c_pipeline.rid)))


func render() -> Image:
	var data = compute_list_process()
	if data == PackedByteArray(): return null

	var image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGBAF, data)
	return image


func compute_list_process() -> PackedByteArray:
	if (not r_device.compute_pipeline_is_valid(c_pipeline.rid) ||
		r_device == null): return PackedByteArray()

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
	var unifrom_set_rid = r_device.uniform_set_create([uniform], c_pipeline.shader_rid, 0)
	
	# Run compute list
	var c_list = r_device.compute_list_begin()
	r_device.compute_list_bind_compute_pipeline(c_list, c_pipeline.rid)
	r_device.compute_list_bind_uniform_set(c_list, unifrom_set_rid, 0)
	r_device.compute_list_dispatch(c_list, width, height, 1)
	r_device.compute_list_end()
#	r_device.compute_list_add_barrier(c_list)
	r_device.submit()
	r_device.sync()
	
	# Get data from buffer
	var data = r_device.buffer_get_data(buffer_rid)
	return data
