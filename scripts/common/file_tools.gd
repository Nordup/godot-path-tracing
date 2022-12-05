class_name FileTools


static func get_file_text(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Cannot open file: " + file_path)
		return ""
	var text = file.get_as_text()
	return text


static func get_file_data(file_path: String) -> PackedByteArray:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Cannot open file: " + file_path)
		return PackedByteArray()
	var data = file.get_buffer(file.get_length())
	return data
