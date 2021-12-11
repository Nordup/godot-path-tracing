extends Node
class_name PathTracing

# Export vars
@export_file var comp_shader
@export_node_path var texture_holder

@export var debug_size: int
@export var debug_mode: bool
@export var loop: bool

# Internal vars
@onready var width = get_viewport().size.x
@onready var height = get_viewport().size.y

var compute: GPUCompute
var img_buffer: SBuffer
var debug_buffer: SBuffer
var uset: USet


func _ready() -> void:
	await get_tree().create_timer(1).timeout # await scene initialization
	if comp_shader == null:
		push_error("Compute shader path is not set")
		return
	
	var c_shader = FileTools.get_file_text(comp_shader)
	compute = GPUCompute.new(c_shader, width, height, 1)
	# create uniform set
	img_buffer = SBuffer.new(
		compute.r_device, width * height * 16, # 4 channels (rgba) 4 bytes each
		PackedByteArray(), 0 # binding
	)
	debug_buffer = SBuffer.new(
		compute.r_device, debug_size * 4,
		PBATools.pba_filled(debug_size * 4, 0), 1 # binding
	)
	uset = USet.new(compute, [img_buffer.uniform, debug_buffer.uniform], 0)
	loop_render()


func loop_render():
	while loop:
		render()


func render() -> void:
	if (compute == null): return
	var msec = Time.get_ticks_msec()
	if debug_mode: print("\nRendering " + str(width) + "x" + str(height))

	compute.dispatch([uset, get_objects_uset()])
	set_image(compute.r_device.buffer_get_data(img_buffer.rid))
	
	if debug_mode: print("Done in " + str(Time.get_ticks_msec() - msec) + "msec")
	if debug_mode: print_float_pba(compute.r_device.buffer_get_data(debug_buffer.rid))


func get_objects_uset() -> USet:
	var cam_pba = SceneCollector.camera.get_data()
	var cam_buffer = SBuffer.new(compute.r_device, cam_pba.size(), cam_pba, 0)
	var spheres_pba = SceneCollector.spheres_pba()
	var spheres_buffer = SBuffer.new(compute.r_device, spheres_pba.size(), spheres_pba, 1)
	return USet.new(compute, [cam_buffer.uniform, spheres_buffer.uniform], 1)


func set_image(rgbaf_pba: PackedByteArray) -> void:
	if rgbaf_pba == null: return
	var image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGBAF, rgbaf_pba)
	var new_texture = ImageTexture.new()
	new_texture.create_from_image(image)
	get_node(texture_holder).texture = new_texture


func print_float_pba(pba: PackedByteArray) -> void:
	print("\nDebug buffer (without 0):")
	for i in range(debug_size):
		var value = pba.decode_float(i * 4)
		if pow(value, 2) > 0.000001 : print(value)
	print("End\n")
