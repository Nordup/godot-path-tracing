class_name PBATools


static func pba_filled(size: int, value: int) -> PackedByteArray:
	var pba = PackedByteArray()
	pba.resize(size)
	pba.fill(value)
	return pba


static func encode_number(x: float, y: float, z: float, w: float) -> PackedByteArray:
	var pba = PackedByteArray()
	pba.resize(4 * 4) # 4 float 4 bytes
	pba.encode_float(0, x)
	pba.encode_float(4, y)
	pba.encode_float(8, z)
	pba.encode_float(12, w)
	return pba


static func encode_float(f: float) -> PackedByteArray:
	return encode_number(f, 0, 0, 0)


static func encode_vec3(vec3: Vector3) -> PackedByteArray:
	return encode_number(vec3.x, vec3.y, vec3.z, 1)


static func encode_euler(euler: Vector3) -> PackedByteArray:
	euler = euler.inverse() # godot uses inverse rotation direction
	return encode_number(euler.x, euler.y, euler.z, 1)


static func encode_quat(quat: Quaternion) -> PackedByteArray:
	quat = quat.inverse() # godot uses inverse rotation direction
	return encode_number(quat.x, quat.y, quat.z, quat.w)


static func encode_clr(color: Color) -> PackedByteArray:
	return encode_number(color.r, color.g, color.b, color.a)
