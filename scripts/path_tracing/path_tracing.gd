extends Node
class_name PathTracing

# Export vars
@export var c_shader: RDShaderFile
@export var debug_size: int
@export_range(3, 10) var ray_depth: int = 5
@export var loop: bool

# Internal vars
var width
var height

# Signals
signal rendered(texure: Texture, render_time: int)

# GPU Compute vars
var compute: GPUCompute

var fixed_uset: USet
var rendered_image: RDTexture
var debug_buffer: SBuffer


func _enter_tree() -> void:
	width = get_viewport().size.x
	height = get_viewport().size.y
	
	assert(c_shader)
	compute = GPUCompute.new(c_shader, width / 8, height / 8, 1)
	fixed_uset = create_fixed_uset()


func _process(_delta: float) -> void:
	if loop: render()


func render() -> void:
	assert(compute)
	var msec = Time.get_ticks_msec()
	
	var glbs_uset = get_globals_uset()
	var objects_uset = get_objects_uset()
	compute.dispatch([fixed_uset, glbs_uset, objects_uset])
	var texture = get_texure(compute.r_device.texture_get_data(rendered_image.rid, 0))
	
	rendered.emit(texture, Time.get_ticks_msec() - msec)


func create_fixed_uset() -> USet:
	rendered_image = RDTexture.new(
		compute.r_device, Vector2i(width, height),
		PBATools.pba_filled(width * height * 16, 0.0), 0 # binding
	)
	debug_buffer = SBuffer.new(
		compute.r_device, debug_size * 4,
		PBATools.pba_filled(debug_size * 4, 0.0), 1 # binding
	)
	return USet.new(compute, [rendered_image.uniform, debug_buffer.uniform], 0)


func get_globals_uset() -> USet:
	var pba = PackedByteArray()
	pba.append_array(PBATools.encode_float(ray_depth))
	pba.append_array(PBATools.encode_float(Time.get_ticks_msec()))
	var glbs_buffer = SBuffer.new(compute.r_device, pba.size(), pba, 0)
	return USet.new(compute, [glbs_buffer.uniform], 1)


func get_objects_uset() -> USet:
	var cam_pba = SceneCollector.camera_pba()
	var cam_buffer = SBuffer.new(compute.r_device, cam_pba.size(), cam_pba, 0)
	var sph_pba = SceneCollector.spheres_pba()
	var sph_buffer = SBuffer.new(compute.r_device, sph_pba.size(), sph_pba, 1)
	return USet.new(compute, [cam_buffer.uniform, sph_buffer.uniform], 2)


func get_texure(rgbaf_pba: PackedByteArray) -> Texture:
	if rgbaf_pba == null: return
	var image = Image.create_from_data(width, height, false, Image.FORMAT_RGBAF, rgbaf_pba)
	return ImageTexture.create_from_image(add_sample(image))


var samples_sum: Image
var count: int = 0
func add_sample(sample: Image) -> Image:
	count += 1
	if samples_sum == null:
		samples_sum = sample
		return sample
	
	var size = samples_sum.get_size()
	for x in size.x:
		for y in size.y:
			var a = samples_sum.get_pixel(x, y) * (count - 1) / count
			var b = sample.get_pixel(x, y) * 1 / count
			samples_sum.set_pixel(x, y, a + b)
	return samples_sum
