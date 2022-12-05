extends Node
class_name PathTracing

# Export vars
@export var c_shader: RDShaderFile
@export var debug_size: int
@export_range(2, 10) var ray_depth: int = 5
@export var loop: bool

# Consts
var width
var height

# Signals
signal rendered(image: Image, render_time: int)

# GPU Compute vars
var compute: GPUCompute

var fixed_uset: USet
var rendered_image: RDTexture
var debug_buffer: SBuffer

var samples_count: float = 0


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
	var rgbaf_pba = compute.r_device.texture_get_data(rendered_image.rid, 0)
	var image = Image.create_from_data(width, height, false, Image.FORMAT_RGBAF, rgbaf_pba)
	samples_count += 1
	
	rendered.emit(image, Time.get_ticks_msec() - msec)


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
	pba.append_array(PBATools.encode_float(samples_count))
	var glbs_buffer = SBuffer.new(compute.r_device, pba.size(), pba, 0)
	return USet.new(compute, [glbs_buffer.uniform], 1)


func get_objects_uset() -> USet:
	var cam_pba = SceneCollector.camera_pba()
	var cam_buffer = SBuffer.new(compute.r_device, cam_pba.size(), cam_pba, 0)
	var sph_pba = SceneCollector.spheres_pba()
	var sph_buffer = SBuffer.new(compute.r_device, sph_pba.size(), sph_pba, 1)
	return USet.new(compute, [cam_buffer.uniform, sph_buffer.uniform], 2)


func clear_samples() -> void:
	samples_count = 0
