@tool
extends LineEdit

signal scene_folder_changed(path)


func _can_drop_data(_at_position, data):
	return true if data.type == "files_and_dirs" else false
	
func _drop_data(_at_position, data):
	scene_folder_changed.emit(data.files[0])
