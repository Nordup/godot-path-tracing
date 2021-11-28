extends Node
class_name ShaderTools


static func create_shader_source(
	compute = "", fragment = "", vertex = "", tesselation = "", evaluation = ""
) -> RDShaderSource:
	var check_and_get = func(file_path: String) -> String:
		var text = ""
		if (file_path != ""):
			text = FileTools.get_file_text(file_path)
		return text
	
	var shader_source = RDShaderSource.new()
	shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
	shader_source.source_compute = check_and_get.call(compute)
	shader_source.source_fragment = check_and_get.call(fragment)
	shader_source.source_vertex = check_and_get.call(vertex)
	shader_source.source_tesselation_control = check_and_get.call(tesselation)
	shader_source.source_tesselation_evaluation = check_and_get.call(evaluation)
	return shader_source


static func fix_compile_erros(shader_spirv: RDShaderSPIRV) -> RDShaderSPIRV:
	if (shader_spirv.bytecode_compute == PackedByteArray()):
		shader_spirv.compile_error_compute = ""
	
	if (shader_spirv.bytecode_fragment == PackedByteArray()):
		shader_spirv.compile_error_fragment = ""
	
	if (shader_spirv.bytecode_tesselation_control == PackedByteArray()):
		shader_spirv.compile_error_tesselation_control = ""
	
	if (shader_spirv.bytecode_tesselation_evaluation == PackedByteArray()):
		shader_spirv.compile_error_tesselation_evaluation = ""
	
	if (shader_spirv.bytecode_vertex == PackedByteArray()):
		shader_spirv.compile_error_vertex = ""
	
	return shader_spirv


static func print_al_compile_errors(shader_spirv: RDShaderSPIRV):
	var print_no_empty = func(text: String):
		if (text != "" && text != "\n"):
			print(text)
	
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_COMPUTE))
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_FRAGMENT))
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_FRAGMENT_BIT))
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_VERTEX))
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_VERTEX_BIT))
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_TESSELATION_CONTROL))
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_TESSELATION_CONTROL_BIT))
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_TESSELATION_CONTROL))
	print_no_empty.call(shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_TESSELATION_CONTROL_BIT))
