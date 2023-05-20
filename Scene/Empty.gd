extends Control

var http: HTTPRequest
@onready var pb: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

var timer: Timer = null
var scenes: Dictionary = _read_json("res://scenes/scenes.json")

func getUrl():
	if OS.get_name() == "Web":
		return JavaScriptBridge.eval(""" 
			window.location.href;
			""")
	return ""

func _ready():
	if OS.get_name() != "Web":
		get_tree().change_scene_to_file(scenes.scene1.scene)
		return
	var scene = scenes.scene1
	http = HTTPRequest.new()
	add_child(http)
	http.download_file = "user://" + scene.filename
	http.connect("request_completed", _file_ready)
	var error = http.request(getUrl() + "/" + scene.filename)
	if error == OK:
		if timer:
			timer.stop()
			timer.queue_free()
		timer = Timer.new()
		add_child(timer)
		timer.connect("timeout", _update)
		timer.start(0.05)
			
func _file_ready(result, response_code, headers, body):
	print("ready", body.size())
	timer.stop()
	var t: Timer = Timer.new()
	add_child(t)
	t.one_shot = true
	t.connect("timeout", _jump_to_scene)
	t.start(2.0)
	
func _jump_to_scene():
	print("jumping...")
	var success = ProjectSettings.load_resource_pack("user://" + scenes.scene1.filename)
	if (success):
		get_tree().change_scene_to_file(scenes.scene1.scene)

func _update():
	http.get_http_client_status()
	pb.max_value = scenes.scene1.size
	pb.value = http.get_downloaded_bytes()
	pass
	
func _read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data
