class_name DialogResourceLoader
extends Node

signal progress(cur: int, max: int, current_filename: String)
signal done()

var store: Dictionary = {}
var request: Array = []
var is_loading: bool = false
var current_index: int = 0


func clear():
	store.clear()
	request = []
	is_loading = false
	current_index = 0

func load(filenames: Array):
	if !is_loading && filenames.size() > 0:
		current_index = 0
		request = filenames
		is_loading = true
		next_file()
	
func next_file():
	if request.size() > 0:
		progress.emit(current_index, request.size(), request[current_index])
		ResourceLoader.load_threaded_request(request[current_index])
	
func _process(_delta):
	if is_loading:
		var arr = []
		var fn = request[current_index]
		ResourceLoader.load_threaded_get_status(fn, arr)
		if arr[0] == 1.0:
			store[fn] = ResourceLoader.load_threaded_get(fn)
			current_index += 1
			if current_index < request.size():
				next_file()
			else:
				is_loading = false
				done.emit()
