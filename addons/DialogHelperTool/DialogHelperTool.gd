@tool
extends Control

var scene_config_data = {}
var timelines_list = {}
@onready var scene_folder = $TabContainer/Scene/MarginContainer/GridContainer/SceneFolder
@onready var scene_file = $TabContainer/Scene/MarginContainer/GridContainer/SceneFile
@onready var timelines_combobox = $TabContainer/Scene/MarginContainer/GridContainer/TimelineList

func _on_scene_folder_changed(path):
	var config_path = path + "config.json"
	if !FileAccess.file_exists(config_path):
		save_json(config_path, {})
		_on_scene_folder_changed(path)
	timelines_list = {}
	timelines_combobox.clear()
	scene_config_data = read_json(config_path)
	scene_folder.text = path
	
	var timelines: Array[String] = get_filelist(path + "timelines", ["json"])
	for k in timelines:
		timelines_list[k.get_file().get_basename()] = k
		timelines_combobox.add_item(k.get_file().get_basename())
	timelines_combobox.selected = timelines_list.keys().find(scene_config_data.start)
	scene_file.text = scene_config_data.scene
	

func read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data
	
func save_json(filename, dict):
	var txt = JSON.stringify(dict)
	var file = FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(txt)
	file.flush()
	file.close()

func get_filelist(scan_dir : String, filter_exts : Array = []) -> Array[String]:
	var my_files : Array[String] = []
	var dir = DirAccess.open(scan_dir)

	if dir.list_dir_begin() != OK:
		printerr("Warning: could not list contents of: ", scan_dir)
		return []

	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name, filter_exts)
		else:
			if filter_exts.size() == 0:
				my_files.append(dir.get_current_dir() + "/" + file_name)
			else:
				for ext in filter_exts:
					if file_name.get_extension() == ext:
						my_files.append(dir.get_current_dir() + "/" + file_name)
		file_name = dir.get_next()
	return my_files
