extends MeshInstance3D
class_name Sphere

class SphereStruct:
	var pos: Color
	var clr: Color
	var r: float


func _ready() -> void:
	SceneCollector.add_sphere(self)

func _exit_tree() -> void:
	SceneCollector.remove_sphere(self)

func get_data() -> PackedByteArray:
	return PackedByteArray()
