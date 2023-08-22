extends Control

@onready var pb: ProgressBar = $Base/ProgressBar
@onready var label: Label = $Base/ProgressBar/Label
@onready var player: AnimationPlayer = $AnimationPlayer
@onready var color = $ColorRect
@onready var shader = $Base/Shader

var appeared = false
	
func _ready():
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	DownloadManager.sceneReady.connect(_scene_ready)
	DownloadManager.progress.connect(_progress)
	
	var scene_name:String = "scene1"
	if DialogState.gs("_next_scene") != "":
		scene_name = DialogState.gs("_next_scene")
	if DialogState.has("load_scene_name"):
		scene_name = DialogState.gs("load_scene_name")
		DialogState.r("load_scene_name")
	
	DownloadManager.downloadScene(scene_name)
	_progress(0.0)
	
func _scene_ready(value: String, scene_name: String):
	var cfg: Dictionary = _read_json(value + "config.json");
	var dict = {
		"timeline": value + "timelines/" + cfg.start + ".json",
		"backgrounds": cfg.backgrounds,
		"videos": cfg.videos,
		"sounds": cfg.sounds,
		"characters": cfg.characters,
		"end": cfg.end,
		"scene_root": value,
		"scene_name": scene_name,
		"timeline_name": cfg.start,
		"clickable_background": false
	}
	if DialogState.has("current_index"):
		dict["current_index"] = DialogState.g("current_index")
		DialogState.r("current_index")
		dict["deep_index"] = DialogState.g("deep_index")
		DialogState.r("deep_index")
	if DialogState.has("load_timeline"):
		dict["timeline_name"] = DialogState.gs("load_timeline")
		dict["timeline"] = value + "timelines/" + DialogState.gs("load_timeline") + ".json"
		DialogState.r("load_timeline")
	if DialogState.g("load_clickable"):
		dict["clickable_background"] = DialogState.g("load_clickable")
		DialogState.r("load_clickable")
	
	player.stop()
	player.play("appear", -1, -10.0, true)
	shader.visible = false
	player.animation_finished.connect(
		func (_v):
			var t = Timer.new()
			t.one_shot = true
			t.timeout.connect(
				func():
					DialogState.setSceneState(dict)
					get_tree().change_scene_to_file(cfg.scene)
					)
			add_child(t)
			t.start(0.05)
			)
	

func _progress(value: float):
	if !appeared:
		player.play("appear", -1, 10.0)
		appeared = true
	pb.value = value*100

func _read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data
