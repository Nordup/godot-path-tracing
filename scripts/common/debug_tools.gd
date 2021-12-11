extends Node
#class_name DebugTools

enum DebugMode {
	None = -1,
	Quiet,
	Full
}

var debug_mode: DebugMode


func set_mode(mode: int) -> void:
	debug_mode = mode
	print("Debug mode: " + DebugMode.keys()[mode + 1])


func _passes(mode: int) -> bool:
	var d: int = debug_mode
	return d >= mode


func printm(value: Variant, mode: DebugMode) -> void:
	if not _passes(mode): return
	print(value)


func print_float_pba(pba: PackedByteArray, mode: DebugMode) -> void:
	if not _passes(mode): return
	for i in range(pba.size() / 4.0):
		var value = pba.decode_float(i * 4)
		if pow(value, 2) > 0.000001 : print(value)
