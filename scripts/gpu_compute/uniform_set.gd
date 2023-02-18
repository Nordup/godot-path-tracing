extends RefCounted
class_name USet

var rid: RID
var index: int
var uniform_array: Array[RDUniform]


func _init(compute: GPUCompute, uniforms: Array[RDUniform], set_index: int) -> void:
	if uniforms.size() < 1:
		push_error("Cannot create USet: Empty RDUniform array")
		return
	
	index = set_index
	uniform_array = uniforms
	rid = compute.r_device.uniform_set_create(uniform_array, compute.shader_rid, index)
