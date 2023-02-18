extends Node
#class_name SceneCollector

var camera: CameraPrimitive
var prim_array: Array[Primitive]


func change_camera(cam: CameraPrimitive) -> void:
#	print("add cam: " + str(cam.name))
	camera = cam

func add_prim(prim: Primitive) -> void:
#	print("add prim: " + str(prim.name))
	prim_array.append(prim)

func remove_prim(prim: Primitive) -> void:
#	print("rem prim: " + str(prim.name))
	prim_array.erase(prim)


func camera_pba() -> PackedByteArray:
	if camera == null: return PackedByteArray()
	return camera.get_data()

func primitives_pba() -> PackedByteArray:
	# Buffer
	var pba = PackedByteArray()
	for i in range(prim_array.size()):
		pba.append_array(prim_array[i].get_data())
	return pba
