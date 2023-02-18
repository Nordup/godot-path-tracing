extends Camera3D
class_name CameraPrimitive

class CameraStruct:
	var pos: Vector3
	var rot: Quaternion
	var fov: float

var camera: CameraStruct


func _ready() -> void:
	SceneCollector.change_camera(self)


func update_data() -> void:
	camera = CameraStruct.new()
	camera.pos = self.position
	camera.rot = self.quaternion
	camera.fov = self.fov


func get_data() -> PackedByteArray:
	update_data()
	var pba = PackedByteArray()
	pba.append_array(PBATools.encode_vec3(camera.pos))
	pba.append_array(PBATools.encode_quat(camera.rot))
	pba.append_array(PBATools.encode_float_x4(camera.fov))
	return pba
