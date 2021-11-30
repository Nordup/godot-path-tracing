extends RefCounted
class_name ComputePipeline

var rid: RID
var shader_rid: RID


func _init(r_device: RenderingDevice, c_shader: String):
	var shader_source = ShaderTools.create_shader_source(c_shader)
	var shader_spirv = r_device.shader_compile_spirv_from_source(shader_source)
	shader_spirv = ShaderTools.fix_compile_erros(shader_source, shader_spirv)
	ShaderTools.print_all_compile_errors(shader_spirv)
	
	shader_rid = r_device.shader_create_from_spirv(shader_spirv)
	rid = r_device.compute_pipeline_create(shader_rid)
