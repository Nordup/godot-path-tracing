extends Node3D
# Tutorial link: https://github.com/godotengine/godot-docs/issues/4834

@export_file var shader_comp
@onready var r_device: RenderingDevice = RenderingServer.create_local_rendering_device()

func _ready():
	var msec = Time.get_ticks_msec()
	var cp = ComputePipeline.new(r_device, shader_comp)
	if (not r_device.compute_pipeline_is_valid(cp.rid)):
		return
	
	compute_list_process(cp)
	print("Done in " + str(Time.get_ticks_msec() - msec) + "msec")
	get_tree().quit()


func compute_list_process(cp: ComputePipeline):
	var pba = PackedByteArray()
	pba.resize(64)
	for i in range(16):
		pba.encode_u8(i*4, 2.0)
	
	var buffer_rid = r_device.storage_buffer_create(64, pba)
	var uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(buffer_rid)
	var u_set_rid = r_device.uniform_set_create([uniform], cp.shader_rid, 0)
	
	# Run compute list
	var c_list = r_device.compute_list_begin()
	r_device.compute_list_bind_compute_pipeline(c_list, cp.rid)
	r_device.compute_list_bind_uniform_set(c_list, u_set_rid, 0)
	r_device.compute_list_dispatch(c_list, 16, 1, 1)
	r_device.compute_list_end()
#	r_device.compute_list_add_barrier(c_list)

	r_device.submit()
	r_device.sync()
	
	# Now we can grab our data from the storage buffer
	var byte_data = r_device.buffer_get_data(buffer_rid)
	for i in range(16):
		print(byte_data.decode_u8(i*4))
