extends RefCounted
class_name GPUCompute

var x_groups: int
var y_groups: int
var z_groups: int

var r_device: RenderingDevice
var c_pipeline: ComputePipeline


func _init(c_shader: String, x: int, y: int, z: int) -> void:
	x_groups = x
	y_groups = y
	z_groups = z
	
	r_device = RenderingServer.create_local_rendering_device()
	c_pipeline = ComputePipeline.new(r_device, c_shader)
	print("Compute pipeline valid: " + str(r_device.compute_pipeline_is_valid(c_pipeline.rid)))


func dispatch(uniform_sets):
	uniform_sets = uniform_sets as Array[USet]
	var c_list = r_device.compute_list_begin()
	r_device.compute_list_bind_compute_pipeline(c_list, c_pipeline.rid)
	
	for i in range(uniform_sets.size()):
		if r_device.uniform_set_is_valid(uniform_sets[i].rid):
			r_device.compute_list_bind_uniform_set(
				c_list, uniform_sets[i].rid, uniform_sets[i].index
			)
		else:
			push_error("Uniform_set is not valid. Index: " + str(i))
			r_device.compute_list_end()
			return
	
	r_device.compute_list_dispatch(c_list, x_groups, y_groups, z_groups)
	r_device.compute_list_end()
	r_device.submit()
	r_device.sync()
