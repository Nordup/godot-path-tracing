extends MeshInstance3D
class_name Primitive

enum PrimitiveType
{
	Sphere,
	Plane
}

enum ReflType
{
	Diffuse,
	Specular,
	Refractive
}

@export_color_no_alpha var color: Color
@export_color_no_alpha var emission: Color
@export var reflection_type: ReflType
