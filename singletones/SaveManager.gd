extends Node

var save_file_path: String = "user://saves.data"

var typeD : Dictionary = {
	"date": "string",
	"scene": "string",
	"timeline": "string",
	"preview": "string",
	"state": "dict",
	"current_index": [0],
	"deep_index": 0
}

var save_state: Dictionary = {
}

func save(page: String, slot: String, data: Dictionary):
	if !save_state.has(page):
		save_state[page] = {}
	save_state[page][slot] = data.duplicate()
	save_json(save_file_path, save_state)
	save_state = read_json(save_file_path)
	
func get_page(page: String):
	if !save_state.has(page):
		return {}
	else:
		return save_state[page].duplicate()
			
func _ready():
	if FileAccess.file_exists(save_file_path):
		save_state = read_json(save_file_path)
	else:
		save_json(save_file_path, save_state)

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
