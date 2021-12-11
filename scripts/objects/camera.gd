extends Camera3D
class_name Camera

class CameraStruct:
	var pos: Vector3
	var dir: Vector3
	var fov: float

var camera: CameraStruct


func _ready() -> void:
	SceneCollector.change_camera(self)
	
	camera = CameraStruct.new()
	camera.pos = self.position
	camera.dir = self.global_transform.basis.z
	camera.fov = self.fov


func get_data() -> PackedByteArray:
	var pba = PackedByteArray()
	pba.append_array(PBATools.vec3_to_vec4(camera.pos))
	pba.append_array(PBATools.vec3_to_vec4(camera.dir))
	pba.append_array(PBATools.float_to_float(camera.fov))
	return pba
