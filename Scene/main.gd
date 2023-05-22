extends Control

@onready var label = $Label
@onready var dialog = $DialogSystem

func _ready():
	var cfg = DialogState.scene_state
	dialog.setDialogParams(cfg)
	
