#[compute]
#version 460


layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;




/* ====================== STRUCTS ====================== */


struct Sphere
{
	vec4 pos;
	float rad;
	vec4 clr;
	vec4 ems; // emission
	float refl; // reflection type (DIFFuse, SPECular, REFRactive)
};


struct Ray
{
	dvec3 pos;
	dvec3 dir;
};




/* ====================== OUPUT BUFFERS ====================== */


layout(set = 0, binding = 0, rgba32f) uniform image2D rendered_image;


layout(set = 0, binding = 1, std430) restrict writeonly buffer DebugBuffer
{
	float data[];
} debug_buffer;




/* ====================== INPUT BUFFERS ====================== */


layout(set = 1, binding = 0, std430) restrict readonly buffer Globals
{
	float Depth;
	float TicksMsec;
	float SamplesCount;
};


layout(set = 2, binding = 0, std430) restrict readonly buffer Camera
{
	vec4 pos;
	vec4 rot;
	float fov;
} camera;


layout(set = 2, binding = 1, std430) restrict readonly buffer SphereBuffer
{
	Sphere[] sphere;
} sphere_buffer;




/* ====================== GLOBAL CONSTS ====================== */


const float PI = 3.14159265358979323846;


// Reflection type (DIFFuse, SPECular, REFRactive)

const float DIFF = 0;
const float SPEC = 1;
const float REFR = 2;


// Runtime global variables

ivec2 inv_id = ivec2(gl_GlobalInvocationID.xy);
ivec2 image_size = imageSize(rendered_image);




/* ====================== FUNCTIONS ====================== */


// Debug

int pIndex = 0;


void print(float f)
{
	debug_buffer.data[pIndex] = 1;
	debug_buffer.data[pIndex + 1] = f;
	pIndex += 2;
}


void print4(vec4 vec)
{
	debug_buffer.data[pIndex] = 4;
	debug_buffer.data[pIndex + 1] = vec.x;
	debug_buffer.data[pIndex + 2] = vec.y;
	debug_buffer.data[pIndex + 3] = vec.z;
	debug_buffer.data[pIndex + 4] = vec.w;
	pIndex += 5;
}


// Main

vec2 seed = vec2(inv_id.x, inv_id.y) + TicksMsec / 1000;
float rand()
{
	vec3 p3  = fract(vec3(seed.xyx) * .1031);
	p3 += dot(p3, p3.yzx + 33.33);
	float result = fract((p3.x + p3.y) * p3.z);

	seed += result * 100;
	return result;
}


double intersect_sphere(const Ray ray, const Sphere sph)
{
	// returns distance, 0 if nohit
	// Solve t^2*d.d + 2*t*(o-p).d + (o-p).(o-p)-R^2 = 0
	dvec3 op = sph.pos.xyz - ray.pos;
	double t, eps = 1e-4;
	double b = dot(op, ray.dir);
	double det = b * b - dot(op, op) + sph.rad * sph.rad;
	if (det < 0)
		return 0;
	else
		det = sqrt(det);
	return (t = b - det) > eps ? t : ((t = b + det) > eps ? t : 0);
}


bool intersect(const Ray ray, inout double t, inout int id)
{
	double d;
	double inf = t = 1e20;
	for (int i = 0; i < sphere_buffer.sphere.length(); i++)
	{
		d = intersect_sphere(ray, sphere_buffer.sphere[i]);
		if (d != 0 && d < t)
		{
			t = d;
			id = i;
		}
	}
	return t < inf;
}


dvec3 radiance(Ray ray)
{
	double t; // distance to intersection
	int id = 0; // id of intersected object
	int depth = 0;

	dvec3 cl = dvec3(0); // accumulated color
	dvec3 cf = dvec3(1); // accumulated reflectance

	int unroll = int(Depth); // Shader compilation loop unrolling
	while (unroll-- > 0)
	{
		if (!intersect(ray, t, id))
			return cl;
		const Sphere sph = sphere_buffer.sphere[id];

		dvec3 hit = ray.pos + ray.dir * t; // hit point
		dvec3 n = normalize(hit - sph.pos.xyz);
		dvec3 nl = dot(n, ray.dir) < 0 ? n : n * -1;
		dvec3 f = sph.clr.xyz;
		double p = max(max(f.x, f.y), f.z); // max refl

		cl = cl + cf * sph.ems.xyz;
		if (++depth > Depth)
			if (rand() < p)
				f = f * (1 / p);
			else
				return cl; // R.R.
		cf = vec3(cf * f);

		if (sph.refl == DIFF)
		{
			// Ideal DIFFUSE reflection

			float r1 = 2 * PI * rand();
			float r2 = rand();
			float r2s = sqrt(r2);

			dvec3 w = nl;
			dvec3 u = normalize(cross((abs(w.x) > .1 ? vec3(0, 1, 0) : vec3(1, 0, 0)), w));
			dvec3 v = cross(w, u);
			dvec3 dir = normalize(u * cos(r1) * r2s + v * sin(r1) * r2s + w * sqrt(1 - r2));
			
			ray = Ray(hit, dir);

			continue; // return sph.ems + f * radiance(Ray(hit,dir),depth,Xi);
		}
		else if (sph.refl == SPEC)
		{
			// Ideal SPECULAR reflection

			ray = Ray(hit, ray.dir - n * 2 * dot(n, ray.dir));

			continue; // return sph.ems + f * radiance(Ray(hit,ray.dir-n*2*dot(n, ray.dir)),depth,Xi);
		}
		else
		{
			// Ideal dielectric REFRACTION

			Ray reflRay = Ray(hit, ray.dir - n * 2 * dot(n, ray.dir));
			bool into = dot(n, nl) > 0; // Ray from outside going in?
			
			double nc = 1;
			double nt = 1.5;
			double nnt = into ? nc / nt : nt / nc;
			double ddn = dot(ray.dir, nl);
			double cos2t;
			
			if ((cos2t = 1 - nnt * nnt * (1 - ddn * ddn)) < 0)
			{
				// Total internal reflection

				ray = reflRay;

				continue; // return sph.ems + f * radiance(reflRay,depth,Xi);
			}

			dvec3 tdir = normalize(ray.dir * nnt - n * ((into ? 1 : -1) * (ddn * nnt + sqrt(cos2t))));
			
			double a = nt - nc;
			double b = nt + nc;
			double R0 = a * a / (b * b);
			double c = 1 - (into ? -ddn : dot(tdir, n));
			double Re = R0 + (1 - R0) * c * c * c * c * c;
			double Tr = 1 - Re;
			double P = .25 + .5 * Re;
			double RP = Re / P;
			double TP = Tr / (1 - P);
			
			if (rand() < P)
			{
				cf = cf * RP;
				ray = reflRay;
			}
			else
			{
				cf = cf * TP;
				ray = Ray(hit, tdir);
			}

			continue;	// return sph.ems + f * rand()<P ?
						//						radiance(reflRay,	depth,Xi)*RP:
						//						radiance(Ray(hit,tdir),depth,Xi)*TP;
		}
	}
}


Ray get_cam_ray()
{
	// TODO: randomize ray
	float fovA = radians(camera.fov / 2);
	float camX = sin(fovA);
	float camZ = -cos(fovA);
	float dX = 2 * camX / image_size.x;
	float dY = dX;
	float camY = (image_size.y / 2) * dY;

	vec3 baseRay = vec3(
		-camX + dX * inv_id.x,
		camY - dY * inv_id.y,
		camZ
	);

	// rotated_vec = vec + 2.0 * cross(cross(vec, quat.xyz) + quat.w * vec, quat.xyz)
	vec3 rotated = baseRay + 2.0 * cross(cross(baseRay, camera.rot.xyz) + camera.rot.w * baseRay, camera.rot.xyz);
	return Ray(camera.pos.xyz, normalize(rotated));
}


void main()
{
	Ray ray = get_cam_ray();
	vec4 pixel = vec4(radiance(ray), 1);

	// Add sample
	if (SamplesCount != 0)
	{
		vec4 texel = imageLoad(rendered_image, inv_id);
		vec4 a = texel * (SamplesCount - 1) / SamplesCount;
		vec4 b = pixel * 1 / SamplesCount;
		pixel = a + b;
	}

	imageStore(rendered_image, inv_id, pixel);


	// Debug

	if (inv_id.x == 0 && inv_id.y == 0)
	{
	}
}