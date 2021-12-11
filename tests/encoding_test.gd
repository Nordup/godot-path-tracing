extends Node2D

func _ready() -> void:
	print("ENCODING_PBA:")
	print("=============================")
	var vec3 = Vector3(0, 1, 2)
	var pba = PBATools.vec3_to_vec4(vec3)
	var res = PBATools.vec3_from_vec4(pba, 0)
	print("Encoding.vec3_to_vec4(" + str(vec3) + ") = " + str(pba))
	print("Encoding.vec3_from_vec4(" + str(pba) + ") = " + str(res))
	print("\nSUCCESS" if vec3 == res  else "FAIL")
	print("=============================")
