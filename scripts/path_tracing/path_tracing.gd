extends Node
class_name PathTracing

# Export vars
@export_file var comp_shader
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
var img_buffer: SBuffer
var debug_buffer: SBuffer


func _enter_tree() -> void:
	width = get_viewport().size.x
	height = get_viewport().size.y
	
	assert(comp_shader)
	var c_shader = FileTools.get_file_text(comp_shader)
	compute = GPUCompute.new(c_shader, width, height, 1)


func _process(_delta: float) -> void:
	if loop: render()


func render() -> void:
	assert(compute)
	var msec = Time.get_ticks_msec()
	
	var uset = create_uset()
	var glbs_uset = get_globals_uset()
	var objects_uset = get_objects_uset()
	compute.dispatch([uset, glbs_uset, objects_uset])
	var texture = get_texure(compute.r_device.buffer_get_data(img_buffer.rid))
	
	rendered.emit(texture, Time.get_ticks_msec() - msec)


func create_uset() -> USet:
	img_buffer = SBuffer.new(
		compute.r_device, width * height * 16, # 4 channels (rgba) 4 bytes each
		PackedByteArray(), 0 # binding
	)
	debug_buffer = SBuffer.new(
		compute.r_device, debug_size * 4,
		PBATools.pba_filled(debug_size * 4, 0), 1 # binding
	)
	return USet.new(compute, [img_buffer.uniform,debug_buffer.uniform], 0)


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
	var image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGBAF, rgbaf_pba)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture
