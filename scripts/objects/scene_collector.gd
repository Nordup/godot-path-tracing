extends Node
#class_name SceneCollector

var camera: Camera
var sphere_array = [] # Array[Sphere]


func change_camera(cam: Camera) -> void:
	print("add cam")
	camera = cam

func add_sphere(sph: Sphere) -> void:
	print("add sph")
	sphere_array.append(sph)

func remove_sphere(sph: Sphere) -> void:
	print("rem sph")
	sphere_array.erase(sph)


func camera_uniform(r_device: RenderingDevice, binding: int) -> RDUniform:
	# Buffer
	var pba = camera.get_data()
	var buffer = r_device.storage_buffer_create(pba.size(), pba)
	
	# Uniform
	var cam_uniform = RDUniform.new()
	cam_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	cam_uniform.binding = binding
	cam_uniform.add_id(buffer)
	return cam_uniform


func sphere_buffer_uniform(r_device: RenderingDevice, binding: int) -> RDUniform:
	# Buffer
	var pba = PackedByteArray()
	for i in range(sphere_array.size()):
		pba.append_array(sphere_array[i].get_data())
	var buffer = r_device.storage_buffer_create(pba.size(), pba)
	
	# Uniform
	var sphere_array_uniform = RDUniform.new()
	sphere_array_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	sphere_array_uniform.binding = binding
	sphere_array_uniform.add_id(buffer)
	return sphere_array_uniform
