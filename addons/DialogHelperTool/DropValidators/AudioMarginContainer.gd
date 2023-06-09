@tool
extends MarginContainer

signal dropped_data(paths)

func _can_drop_data(_at_position: Vector2, data: Variant):
	return data.type == "files" && validate(data.files)
	
func validate(array):
	var allowed_ext = ["mp3", "ogg", "wma"]
	for i in array:
		var s: String = i
		if !allowed_ext.has(s.get_extension()):
			return false
	return true
		
func _drop_data(_at_position, data):
	dropped_data.emit(data.files)
	
