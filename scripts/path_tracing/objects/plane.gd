extends Sphere
class_name Plane

class PlaneStruct:
	var pos: Vector3
	var norm : Vector3
	var clr: Color
	var ems: Color
	var refl: int

@export var norm: Vector3


var plane: PlaneStruct

func _ready() -> void:
	SceneCollector.add_sphere(self)


func update_data() -> void:
	plane = PlaneStruct.new()
	plane.pos = self.position
	plane.norm = norm
	plane.clr = color
	plane.ems = emission
	plane.refl = reflection_type


func get_data() -> PackedByteArray:
	update_data()
	var pba = PackedByteArray()
	pba.append_array(PBATools.encode_float_x4(ObjectType.Plane))
	pba.append_array(PBATools.encode_vec3(plane.pos))
	pba.append_array(PBATools.encode_vec3(plane.norm))
	pba.append_array(PBATools.encode_color(plane.clr))
	pba.append_array(PBATools.encode_color(plane.ems))
	pba.append_array(PBATools.encode_float_x4(float(plane.refl)))
	return pba


func _exit_tree() -> void:
	SceneCollector.remove_sphere(self)
