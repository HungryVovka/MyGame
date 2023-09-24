class_name SceneLoader
extends Control

@export_file("*.tscn") var source: String
signal on_ready(src: Resource)
signal on_progress(value: float)

var is_loading = false

func load(s: String):
	source = s
	ResourceLoader.load_threaded_request(source)
	is_loading = true

func _process(_delta):
	if is_loading:
		var arr = []
		ResourceLoader.load_threaded_get_status(source, arr)
		on_progress.emit(arr[0])
		if arr[0] == 0.0 || arr[0] == 1.0:
			is_loading = false
			var s = ResourceLoader.load_threaded_get(source)
			on_ready.emit(s)
