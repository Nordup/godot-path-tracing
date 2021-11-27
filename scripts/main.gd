extends Node3D

@export_file var shader_comp


func _ready():
	var msec = Time.get_ticks_msec()
	run_compute()
	print("Done in " + str(Time.get_ticks_msec() - msec) + "msec")


func run_compute():
#	var r_device = RenderingServer.get_rendering_device()
	var r_device = RenderingServer.create_local_rendering_device()
	var c_pipeline_rid = create_compute_pipeline(r_device, shader_comp)
	# Run compute list once
	compute_list_process(r_device, c_pipeline_rid)


func create_compute_pipeline(r_device: RenderingDevice, shader_comp_path: String) -> RID:
	var shader_source = ShaderTools.create_shader_source(shader_comp_path)
	var shader_spirv = r_device.shader_compile_spirv_from_source(shader_source)
	shader_spirv = ShaderTools.fix_compile_erros(shader_spirv)
	ShaderTools.print_al_compile_errors(shader_spirv)
	
	var shader_rid = r_device.shader_create_from_spirv(shader_spirv)
	var c_pipeline_rid = r_device.compute_pipeline_create(shader_rid)
	print("Compute pipeline is valid: " + str(r_device.compute_pipeline_is_valid(c_pipeline_rid)))
	return c_pipeline_rid


func compute_list_process(r_device: RenderingDevice, c_pipeline_rid: RID):
	var c_list = r_device.compute_list_begin()
	r_device.compute_list_bind_compute_pipeline(c_list, c_pipeline_rid)
	
	# Bind other needed data here
	
	# Run compute list
	r_device.compute_list_dispatch(
		c_list,
		r_device.LIMIT_MAX_COMPUTE_WORKGROUP_COUNT_X,
		r_device.LIMIT_MAX_COMPUTE_WORKGROUP_COUNT_Y,
		r_device.LIMIT_MAX_COMPUTE_WORKGROUP_COUNT_Z
	)
	r_device.compute_list_end()
