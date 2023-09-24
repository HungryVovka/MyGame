extends "res://addons/DialogHelperTool/Game/DialogScene/DialogLayout.gd"

@onready var bar = $Control/ProgressBar
var tween: Tween
func _ready():
	super()
	backgroundSceneContainer = $VideoPlayer/BackgroundCompose/CustomBackgroundContainer
	downloader.connect("progress", progress)
	downloader.connect("done", resourcesReady)
	dialogManager.onSignal.connect(processSignal)
	
func processSignal(name: String, params: Dictionary):
	if name == "relation":
		$RelationBackground.visible = true
		$RelationBackground.fadeIn()
		
func progress(curr: int, _max: int, _fn: String):
	var old_value = bar.value
	bar.max_value = _max
	if tween:
		tween.kill()
		
	tween = get_tree().create_tween()
	tween.tween_property(bar, "value", curr, 0.2)
	$Control/ProgressBar/Label.text = _fn
	
func resourcesReady():
	$Control.visible = false

func _on_relation_background_on_next():
	$RelationBackground.visible = false
