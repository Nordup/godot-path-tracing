extends Node
class_name PathTracing

# Export vars
@export_file var comp_shader
@export var debug_size: int
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
var uset: USet


func _enter_tree() -> void:
	width = get_viewport().size.x
	height = get_viewport().size.y
	
	assert(comp_shader)
	var c_shader = FileTools.get_file_text(comp_shader)
	compute = GPUCompute.new(c_shader, width, height, 1)
	create_uset()


func create_uset() -> void:
	assert(compute)
	img_buffer = SBuffer.new(
		compute.r_device, width * height * 16, # 4 channels (rgba) 4 bytes each
		PackedByteArray(), 0 # binding
	)
	debug_buffer = SBuffer.new(
		compute.r_device, debug_size * 4,
		PBATools.pba_filled(debug_size * 4, 0), 1 # binding
	)
	uset = USet.new(compute, [img_buffer.uniform, debug_buffer.uniform], 0)


func _process(_delta: float) -> void:
	if loop: render()


func render() -> void:
	assert(compute)
	var msec = Time.get_ticks_msec()
	
	var objects_uset = get_objects_uset()
	compute.dispatch([uset, objects_uset])
	var texture = get_texure(compute.r_device.buffer_get_data(img_buffer.rid))
	
	rendered.emit(texture, Time.get_ticks_msec() - msec)


func get_objects_uset() -> USet:
	var cam_pba = SceneCollector.camera.get_data()
	var cam_buffer = SBuffer.new(compute.r_device, cam_pba.size(), cam_pba, 0)
	var spheres_pba = SceneCollector.spheres_pba()
	var spheres_buffer = SBuffer.new(compute.r_device, spheres_pba.size(), spheres_pba, 1)
	return USet.new(compute, [cam_buffer.uniform, spheres_buffer.uniform], 1)


func get_texure(rgbaf_pba: PackedByteArray) -> Texture:
	if rgbaf_pba == null: return
	var image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGBAF, rgbaf_pba)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture
