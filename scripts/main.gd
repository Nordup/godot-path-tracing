extends Node3D

@export_file var shader_comp

func _ready():
#	var r_device = RenderingServer.create_local_rendering_device()
	var r_device = RenderingServer.get_rendering_device()
	var c_pipeline_rid = create_compute_pipeline(r_device)
	create_compute_list(r_device, c_pipeline_rid)


func create_compute_pipeline(r_device: RenderingDevice) -> RID:
	var shader_source = ShaderTools.create_shader_source(shader_comp)
	var shader_spirv = r_device.shader_compile_spirv_from_source(shader_source)
	shader_spirv = ShaderTools.fix_compile_erros(shader_spirv)
	ShaderTools.print_al_compile_errors(shader_spirv)
	
	var shader_rid = r_device.shader_create_from_spirv(shader_spirv)
	var c_pipeline_rid = r_device.compute_pipeline_create(shader_rid)
	print("Pipeline is valid: " + str(
		r_device.compute_pipeline_is_valid(c_pipeline_rid)
		) + "\n")
	return c_pipeline_rid


func create_compute_list(r_device: RenderingDevice, c_pipeline_rid: RID):
	var c_list = r_device.compute_list_begin()
	r_device.compute_list_bind_compute_pipeline(c_list, c_pipeline_rid)
	
