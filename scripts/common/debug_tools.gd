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


func print_float_pba_quiet(pba: PackedByteArray) -> void: print_float_pba(pba, DebugMode.Quiet)
func print_float_pba_full(pba: PackedByteArray) -> void: print_float_pba(pba, DebugMode.Full)

func print_float_pba(pba: PackedByteArray, mode: DebugMode) -> void:
	if not _passes(mode): return
	for i in range(pba.size() / 4.0):
		var value = pba.decode_float(i * 4)
		if pow(value, 2) > 0.000001 : print(value)
