extends MeshInstance3D
class_name Sphere

class SphereStruct:
	var rad : float
	var pos: Vector3
	var clr: Color
	var ems: Color
	var refl: ReflType

enum ReflType { Diffuse, Specular, Refractive }
@export var radius: float
@export_color_no_alpha var color: Color
@export_color_no_alpha var emission: Color
@export var reflection_type: ReflType


var sphere: SphereStruct

func _ready() -> void:
	SceneCollector.add_sphere(self)


func update_data() -> void:
	sphere = SphereStruct.new()
	sphere.rad = radius
	sphere.pos = self.position
	sphere.clr = color
	sphere.ems = emission
	sphere.refl = reflection_type


func get_data() -> PackedByteArray:
	update_data()
	var pba = PackedByteArray()
	pba.append_array(PBATools.encode_float(sphere.rad))
	pba.append_array(PBATools.encode_vec3(sphere.pos))
	pba.append_array(PBATools.encode_color(sphere.clr))
	pba.append_array(PBATools.encode_color(sphere.ems))
	pba.append_array(PBATools.encode_float(float(sphere.refl)))
	return pba


func _exit_tree() -> void:
	SceneCollector.remove_sphere(self)
