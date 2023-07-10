extends Node

var save_file_path: String = "user://saves.data"

var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()

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
	JSONHelper.save_json(save_file_path, save_state)
	save_state = JSONHelper.read_json(save_file_path)
	
func get_page(page: String):
	if !save_state.has(page):
		return {}
	else:
		return save_state[page].duplicate()

func load(page: String, index: String):
	return JSONHelper.deep_duplicate(get_page(page)[index])
			
func _ready():
	if FileAccess.file_exists(save_file_path):
		save_state = JSONHelper.read_json(save_file_path)
	else:
		JSONHelper.save_json(save_file_path, save_state)
