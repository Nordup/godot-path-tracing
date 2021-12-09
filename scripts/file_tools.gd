extends Object
class_name FileTools


static func get_file_text(file_path: String) -> String:
	var file = File.new()
	var err = file.open(file_path, File.READ_WRITE)
	if err != OK:
		push_error("Cannot open file: " + file_path)
		return ""
	var text = file.get_as_text()
	file.close()
	return text


static func get_file_data(file_path: String) -> PackedByteArray:
	var file = File.new()
	var err = file.open(file_path, File.READ_WRITE)
	if err != OK:
		push_error("Cannot open file: " + file_path)
		return PackedByteArray()
	var data = file.get_buffer(file.get_length())
	file.close()
	return data
