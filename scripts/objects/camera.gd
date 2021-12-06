extends Camera3D
class_name Camera

class CameraStruct:
	var pos: Color
	var dir: Color
	var fov: float


func _ready() -> void:
	SceneCollector.change_camera(self)

func get_data() -> PackedByteArray:
	return PackedByteArray()
