vec3 rotate_vector(vec3 vec, vec3 euler)
{
	mat4 rmat_x = mat4(
		vec4(1,	0,				0,				0),
		vec4(0,	cos(euler.x),	-sin(euler.x),	0),
		vec4(0,	sin(euler.x),	cos(euler.x),	0),
		vec4(0,	0,				0,				1)
	);
	mat4 rmat_y = mat4(
		vec4(cos(euler.y),	0,	sin(euler.y),	0),
		vec4(0,				1,	0,				0),
		vec4(-sin(euler.y),	0,	cos(euler.y),	0),
		vec4(0,				0,	0,				1)
	);
	mat4 rmat_z = mat4(
		vec4(cos(euler.z),	-sin(euler.z),	0,	0),
		vec4(sin(euler.z),	cos(euler.z),	0,	0),
		vec4(0,				0,				1,	0),
		vec4(0,				0,				0,	1)
	);
	vec4 res = rmat_y * rmat_x * rmat_z * vec4(vec, 1);
	return res.xyz;
}


vec3 rotate_vector(vec3 vec, vec4 quat)
{
	return vec + 2.0 * cross(cross(vec, quat.xyz) + quat.w * vec, quat.xyz);
}