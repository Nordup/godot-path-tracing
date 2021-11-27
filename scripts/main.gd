extends Node3D

@export_file var shader_comp


func _ready():
	compile_shader()


func compile_shader():
	var rendering_device = RenderingServer.get_rendering_device()
	var shader_source = ShaderTools.create_shader_source(shader_comp)
	var shader_spirv = rendering_device.shader_compile_spirv_from_source(shader_source)
	shader_spirv = ShaderTools.fix_compile_erros(shader_spirv)
	ShaderTools.print_al_compile_errors(shader_spirv)
	
	var shader_rid = rendering_device.shader_create_from_spirv(shader_spirv)
	var compute_pipeline_rid = rendering_device.compute_pipeline_create(shader_rid)
	print("Pipeline is valid: " + str(
		rendering_device.compute_pipeline_is_valid(compute_pipeline_rid)
		) + "\n")
