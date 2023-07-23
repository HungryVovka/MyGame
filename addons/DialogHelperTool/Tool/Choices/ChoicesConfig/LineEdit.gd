@tool
extends LineEdit

func _can_drop_data(at_position, data):
	return data.type == "files" && data.files[0].contains(".tscn")
	
func _drop_data(at_position, data):
	text = data.files[0]
	text_changed.emit(text)
