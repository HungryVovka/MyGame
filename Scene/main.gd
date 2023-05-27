extends Control

@export_file("*.json") var backgrounds
@export_file("*.json") var timeline
@export_file("*.json") var videos
@export_file("*.json") var sounds
@export_file("*.json") var characters

@onready var label = $Label
@onready var dialog = $DialogSystem
@onready var menu = $GameMenu
@onready var menuPlayer = $MenuPlayer

var menu_is_hiding = false

var dict = {
	"timeline": timeline,
	"backgrounds": backgrounds,
	"videos": videos,
	"sounds": sounds,
	"characters": characters,
	"scene_root": "res://Resources/Scene1/",
	"end": ""
}

var cached_save = {}


func _ready():
	var cfg = DialogState.scene_state
	if cfg.is_empty():
		dialog.setDialogParams(dict)
	else:
		dialog.setDialogParams(cfg)
	
	menuPlayer.animation_finished.connect(func(_name):
		if menu_is_hiding:
			menu.visible = false
			menu_is_hiding = false
		)
		
func _input(event):
	if event is InputEventKey:
		if Input.is_action_pressed("QuickSave"):
			SaveManager.save("Q", "1", dialog.save())
		if Input.is_action_just_pressed("Menu"):
			if !menu.visible:
				menu.visible = true
				menu_is_hiding = false
				menuPlayer.play("menu_appear",-1, 1.5)
				cached_save = dialog.save()
			else: 
				menu_is_hiding = true
				menuPlayer.play("menu_appear", -1, -1.5, true)
	
func _on_game_menu_save_picked(page, num):
	SaveManager.save(page, num, cached_save)
	menu.loadSaveRender()
