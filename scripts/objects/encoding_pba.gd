class_name EncodingPBA


static func float_to_float(number: float) -> PackedByteArray:
	var pba = PackedByteArray()
	pba.resize(4) # 1 float 4 bytes
	pba.encode_float(0, number)
	return pba


static func vec3_to_vec4(vec3: Vector3) -> PackedByteArray:
	var pba = PackedByteArray()
	pba.resize(4 * 4) # 4 float 4 bytes
	pba.encode_float(0, vec3.x)
	pba.encode_float(4, vec3.y)
	pba.encode_float(8, vec3.z)
	pba.encode_float(12, 1)
	return pba


static func clr_to_vec4(color: Color) -> PackedByteArray:
	var pba = PackedByteArray()
	pba.resize(4 * 4) # 4 float 4 bytes
	pba.encode_float(0, color.r)
	pba.encode_float(4, color.g)
	pba.encode_float(8, color.b)
	pba.encode_float(12, color.a)
	return pba


static func vec3_from_vec4(pba: PackedByteArray, byte_offset: int) -> Vector3:
	var vec3 = Vector3()
	vec3.x = pba.decode_float(byte_offset + 0)
	vec3.y = pba.decode_float(byte_offset + 4)
	vec3.z = pba.decode_float(byte_offset + 8)
	return vec3
