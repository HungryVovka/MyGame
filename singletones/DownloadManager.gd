extends Node

@export var downloadMode = false
signal progress(value: float)
signal sceneReady(value: String, request_name: String)

var http: HTTPRequest
var timer: Timer = null
var scenes: Dictionary = _read_json("res://scenes/scenes.json")
var downloadSize = 1
var busy = false

func _ready():
	DirAccess.make_dir_absolute("user://Scenes/")
	pass
	
func _need_downloading(filename: String, headers):
	var cache = _generate_cachefile(headers)
	var fn = "user://Scenes/" + filename + ".cache"
	if FileAccess.file_exists(fn):
		var dict = _read_json(fn)
		return dict.cl != cache.cl || dict.etag != cache.etag
	else:
		return true

func _save_cachefile(filename, headers):
	_save_json("user://Scenes/" + filename + ".cache", _generate_cachefile(headers))
	
func _generate_cachefile(headers):
	var cl_header: String
	var etag_header: String
	for h in headers:
		if h.contains("Content-Length:"):
			cl_header = h
		if h.to_lower().contains("etag"):
			etag_header = h
	var result: Dictionary = {}
	result.cl = cl_header
	result.etag = etag_header
	return result
		

func downloadScene(sceneName: String):
	if !downloadMode:
		sceneReady.emit(scenes[sceneName].scene, sceneName)
		return
	
	var scene = scenes[sceneName]
	var head = HTTPRequest.new()
	head.request_completed.connect(
		func (result, _response_code, headers: PackedStringArray, _body): 
			if (result == OK):
				for h in headers:
					if h.contains("Content-Length:"):
						downloadSize = int(h.split(" ")[1])
				if _need_downloading(scene.filename, headers):
					http = HTTPRequest.new()
					add_child(http)
					http.download_file = "user://Scenes/" + scene.filename
					http.request_completed.connect(
						func (_result, _response_code, _headers, _body):
							timer.stop()
							var t: Timer = Timer.new()
							add_child(t)
							t.one_shot = true
							t.timeout.connect(
								func():
									print("jumping...")
									_save_cachefile(scene.filename, headers)
									var success = ProjectSettings.load_resource_pack("user://Scenes/" + scene.filename)
									if (success):
										sceneReady.emit(scene.scene, sceneName)
									)
							t.start(2.0)
							)
					var error = http.request(scene.url)
					if error == OK:
						if timer:
							timer.stop()
							timer.queue_free()
						timer = Timer.new()
						add_child(timer)
						timer.connect("timeout", func():
							print(http.get_downloaded_bytes())
							progress.emit(http.get_downloaded_bytes() * 1.0 / downloadSize))
						timer.start(0.05)
				else:
					var success = ProjectSettings.load_resource_pack("user://Scenes/" + scene.filename)
					if (success):
						sceneReady.emit(scenes[sceneName].scene, sceneName)
				)
	add_child(head)
	head.request(scene.url, [], HTTPClient.METHOD_HEAD);
	
func _read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data
	
func _save_json(filename, data):
	var file: FileAccess = FileAccess.open(filename, FileAccess.WRITE)
	var txt = JSON.stringify(data)
	file.store_string(txt)
	file.flush()
	file.close()
