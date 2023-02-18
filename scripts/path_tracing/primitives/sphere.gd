extends Primitive
class_name SpherePrimitive

class SphereStruct:
	var pos: Vector3
	var rad : float
	var clr: Color
	var ems: Color
	var refl: ReflType

@export var radius: float


var sphere: SphereStruct

func _ready() -> void:
	SceneCollector.add_prim(self)


func update_data() -> void:
	sphere = SphereStruct.new()
	sphere.pos = self.position
	sphere.rad = radius
	sphere.clr = color
	sphere.ems = emission
	sphere.refl = reflection_type


func get_data() -> PackedByteArray:
	update_data()
	var pba = PackedByteArray()
	pba.append_array(PBATools.encode_float_x4(PrimitiveType.Sphere))
	pba.append_array(PBATools.encode_vec3(sphere.pos))
	pba.append_array(PBATools.encode_float_x4(sphere.rad))
	pba.append_array(PBATools.encode_color(sphere.clr))
	pba.append_array(PBATools.encode_color(sphere.ems))
	pba.append_array(PBATools.encode_float_x4(float(sphere.refl)))
	return pba


func _exit_tree() -> void:
	SceneCollector.remove_prim(self)
