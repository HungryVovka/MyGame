@tool
extends Node

func read_json(filename, globalize = true):
	var path = filename if !globalize else ProjectSettings.globalize_path(filename)
	var file = FileAccess.open(path, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data
	
func save_json(filename, dict, globalize = true):
	var path = filename if !globalize else ProjectSettings.globalize_path(filename)
	var txt = JSON.stringify(dict,"\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(txt)
	file.flush()
	file.close()
	
func gs(dict: Dictionary, key):
	if dict.has(key):
		var result = dict[key]
		if result == "":
			dict[key] = ""
		return result
	return ""
