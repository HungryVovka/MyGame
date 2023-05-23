extends Control

@export_file("*.json") var backgrounds
@export_file("*.json") var timeline
@export_file("*.json") var videos
@export_file("*.json") var sounds
@export_file("*.json") var characters

@onready var label = $Label
@onready var dialog = $DialogSystem

var dict = {
	"timeline": timeline,
	"backgrounds": backgrounds,
	"videos": videos,
	"sounds": sounds,
	"characters": characters,
	"end": ""
}


func _ready():
	var cfg = DialogState.scene_state
	if cfg.is_empty():
		dialog.setDialogParams(dict)
	else:
		dialog.setDialogParams(cfg)
	
