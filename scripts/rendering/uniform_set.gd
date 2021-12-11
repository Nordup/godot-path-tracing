extends RefCounted
class_name USet

var rid: RID
var index: int
var uniform_array # Array[RDUniform]


func _init(compute: Compute, uniforms, set_index) -> void:
	uniforms = uniforms as Array[RDUniform]
	if uniforms.size() < 1:
		push_error("Cannot create USet: Empty RDUniform array")
		return
	
	index = set_index
	uniform_array = uniforms
	rid = compute.r_device.uniform_set_create(uniform_array, compute.c_pipeline.shader_rid, index)
