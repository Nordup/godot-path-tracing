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
	return RDUniform.new()

func sphere_buffer_uniform(r_device: RenderingDevice, binding: int) -> Array[RDUniform]:
	var uniforms = [RDUniform.new()]
	return uniforms
