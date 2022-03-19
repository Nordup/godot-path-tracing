extends Camera3D
class_name Camera

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
	camera.rot = self.quaternion.inverse()
	camera.fov = self.fov


func get_data() -> PackedByteArray:
	update_data()	
	var pba = PackedByteArray()
	pba.append_array(PBATools.vec3_to_vec4(camera.pos))
	pba.append_array(PBATools.quaternion_to_vec4(camera.rot))
	pba.append_array(PBATools.float_to_float(camera.fov))
	return pba
