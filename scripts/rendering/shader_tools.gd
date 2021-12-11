class_name ShaderTools


static func create_shader_source(
	compute = "", fragment = "", vertex = "", tesselation = "", evaluation = ""
) -> RDShaderSource:
	var shader_source = RDShaderSource.new()
	shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
	shader_source.source_compute = compute
	shader_source.source_fragment = fragment
	shader_source.source_vertex = vertex
	shader_source.source_tesselation_control = tesselation
	shader_source.source_tesselation_evaluation = evaluation
	return shader_source


static func fix_compile_erros(shader_source: RDShaderSource, shader_spirv: RDShaderSPIRV) -> RDShaderSPIRV:
	if (shader_source.source_compute == ""):
		shader_spirv.compile_error_compute = ""
	
	if (shader_source.source_fragment == ""):
		shader_spirv.compile_error_fragment = ""
	
	if (shader_source.source_vertex == ""):
		shader_spirv.compile_error_vertex = ""
	
	if (shader_source.source_tesselation_control == ""):
		shader_spirv.compile_error_tesselation_control = ""
	
	if (shader_source.source_tesselation_evaluation == ""):
		shader_spirv.compile_error_tesselation_evaluation = ""
	
	return shader_spirv


static func print_all_compile_errors(shader_spirv: RDShaderSPIRV) -> void:
	var print_error = func(shader_stage: int):
		var error_text = shader_spirv.get_stage_compile_error(shader_stage)
		if (error_text != null && error_text != "" && error_text != "\n"):
			print(error_text)
	
	print_error.call(RenderingDevice.SHADER_STAGE_COMPUTE)
	print_error.call(RenderingDevice.SHADER_STAGE_FRAGMENT)
	print_error.call(RenderingDevice.SHADER_STAGE_VERTEX)
	print_error.call(RenderingDevice.SHADER_STAGE_TESSELATION_CONTROL)
	print_error.call(RenderingDevice.SHADER_STAGE_TESSELATION_CONTROL)
