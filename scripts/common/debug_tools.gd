extends Node
#class_name DebugTools

enum DebugMode {
	None = -1,
	Quiet,
	Full
}

var debug_mode: DebugMode


func set_mode(mode: DebugMode) -> void:
	debug_mode = mode
	print("Debug mode: " + DebugMode.keys()[mode + 1])


func _passes(mode: DebugMode) -> bool:
	var d: int = debug_mode
	return d >= mode


func print_quiet(value: Variant) -> void: printm(value, DebugMode.Quiet)
func print_full(value: Variant) -> void: printm(value, DebugMode.Full)

func printm(value: Variant, mode: DebugMode) -> void:
	if not _passes(mode): return
	print(value)


func print_debug_buffer_quiet(pba: PackedByteArray) -> void: print_debug_buffer(pba, DebugMode.Quiet)
func print_debug_buffer_full(pba: PackedByteArray) -> void: print_debug_buffer(pba, DebugMode.Full)

func print_debug_buffer(pba: PackedByteArray, mode: DebugMode) -> void:
	if not _passes(mode): return
	
	var i = 0
	while i < pba.size() / 4.0:
		var size = pba.decode_float(i * 4) # get number of floats in line
		if (size == 0): break
		
		var text = "";
		for n in size:
			var index = i + 1 + n
			text += str(pba.decode_float(index * 4))
			text += "\t" if n + 1 < size else ""
		print(text)
		
		i += 1 + size
