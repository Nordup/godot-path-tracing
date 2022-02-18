extends Node
#class_name SceneCollector

var camera: Camera
var sphere_array = [] # Array[Sphere]


func change_camera(cam: Camera) -> void:
#	print("add cam: " + str(cam.name))
	camera = cam

func add_sphere(sph: Sphere) -> void:
#	print("add sph: " + str(sph.name))
	sphere_array.append(sph)

func remove_sphere(sph: Sphere) -> void:
#	print("rem sph: " + str(sph.name))
	sphere_array.erase(sph)


func camera_pba() -> PackedByteArray:
	if camera == null: return PackedByteArray()
	return camera.get_data()

func spheres_pba() -> PackedByteArray:
	# Buffer
	var pba = PackedByteArray()
	for i in range(sphere_array.size()):
		pba.append_array(sphere_array[i].get_data())
	return pba
