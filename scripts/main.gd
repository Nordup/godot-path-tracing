extends Node3D
# Tutorial link: https://github.com/godotengine/godot-docs/issues/4834

@export_file var shader_comp
@onready var r_device: RenderingDevice = RenderingServer.create_local_rendering_device()

func _ready():
	var msec = Time.get_ticks_msec()
	var cp = ComputePipeline.new(r_device, shader_comp)
	if (not r_device.compute_pipeline_is_valid(cp.rid)):
		return
	
#	compute_list_process(cp)
	print("Done in " + str(Time.get_ticks_msec() - msec) + "msec")


func compute_list_process(cp: ComputePipeline):
	# Bind needed data here
	var image_data = PackedByteArray()
	var buffer_rid = r_device.storage_buffer_create(image_data.size() * 1)
	var uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER
	uniform.binding = 0
	uniform.add_id(buffer_rid)
	var u_set_rid = r_device.uniform_set_create([uniform], cp.shader_rid, 0)
	
	# Run compute list
	var c_list = r_device.compute_list_begin()
	r_device.compute_list_bind_compute_pipeline(c_list, cp.rid)
	r_device.compute_list_bind_uniform_set(c_list, u_set_rid, 0)
	r_device.compute_list_dispatch(c_list, 2, 1, 1)
	r_device.compute_list_end()
#	r_device.compute_list_add_barrier(c_list)

	r_device.submit()
	r_device.sync()
