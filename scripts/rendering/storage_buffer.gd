extends RefCounted
class_name SBuffer

var rid: RID
var uniform: RDUniform


func _init(r_device: RenderingDevice, size: int, data: PackedByteArray, binding: int):
	rid = r_device.storage_buffer_create(size, data)
	
	# Uniform
	uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding
	uniform.add_id(rid)
