@tool
extends Node

signal reimport(filename)

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
	reimport.emit(path)
	
func delay(callback: Callable, time = 1.0):
	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", callback)
	timer.connect("timeout", func (): timer.queue_free())
	timer.start(time)
	
func later(callback: Callable):
	delay(callback, 0.01)

func deep_duplicate(dict: Dictionary):
	var data = JSON.stringify(dict)
	return JSON.parse_string(data)
	
func gs(dict: Dictionary, key):
	if dict.has(key):
		var result = dict[key]
		if result == "":
			dict[key] = ""
		return result
	return ""
	
func gb(dict: Dictionary, keys = []):
	for k in keys:
		if dict.has(k) && dict[k]:
			return true
	return false
