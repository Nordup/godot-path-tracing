extends MeshInstance3D
class_name Sphere

class SphereStruct:
	var pos: Vector3
	var clr: Color
	var r: float

var sphere: SphereStruct


func _ready() -> void:
	SceneCollector.add_sphere(self)


func update_data() -> void:
	var sphere_mesh = self.mesh as SphereMesh
	var material = sphere_mesh.material as StandardMaterial3D
	
	sphere = SphereStruct.new()
	sphere.pos = self.position
	sphere.r = sphere_mesh.radius
	sphere.clr = material.albedo_color


func get_data() -> PackedByteArray:
	update_data()
	var pba = PackedByteArray()
	pba.append_array(PBATools.vec3_to_vec4(sphere.pos))
	pba.append_array(PBATools.clr_to_vec4(sphere.clr))
	pba.append_array(PBATools.float_to_float(sphere.r))
	return pba


func _exit_tree() -> void:
	SceneCollector.remove_sphere(self)
