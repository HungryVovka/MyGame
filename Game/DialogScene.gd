extends Control

@onready var textArea = $TextAreaContainer/TextArea
@onready var dialogManager
@onready var audioManager
@onready var background = $Background
@onready var choicesBlock = $ChoicesBlock
@onready var videoPlayer = $VideoPlayer
@onready var choiceSceneContainer = $CustomChoiceSceneContainer
@onready var persons = $PersonLayout

@export var clickable_background = false

@export_file("*.json") var fn: String

var choiceSceneChild: Node

var scene_root = ""
var scene_ready = false
var scene_src_params = {}

var typeD : Dictionary = {
	"date": "string",
	"scene": "string",
	"timeline": "string",
	"preview": "string",
	"state": "dict",
	"current_index": [0],
	"deep_index": 0
}



func _ready():
	choicesBlock.visible = false
	
	dialogManager = preload("res://addons/DialogHelperTool/Game/DialogManager/DialogManager.tscn").instantiate()
	add_child(dialogManager)
	dialogManager.connect("end", _on_dialog_manager_end)
	dialogManager.connect("personAnimation", person_animation)
	dialogManager.connect("personSource", set_person_source)
	dialogManager.connect("personVisible", set_person_visible)
	dialogManager.connect("playSound", _on_dialog_manager_play_sound)
	dialogManager.connect("playVideo", _on_dialog_manager_play_video)
	dialogManager.connect("resetCharacter", _on_dialog_manager_reset_character)
	dialogManager.connect("setBackground", _on_dialog_manager_set_background)
	dialogManager.connect("setBackgroundClickable", _on_dialog_manager_set_background_clickable)
	dialogManager.connect("showChoices", _on_dialog_manager_show_choices)
	dialogManager.connect("stopSound", _on_dialog_manager_stop_sound)
	dialogManager.connect("stopVideo", _on_dialog_manager_stop_video)
	dialogManager.connect("updateCharacter", _on_dialog_manager_update_character)
	dialogManager.connect("updateText", _on_dialog_manager_update_text)
	dialogManager.timeline = fn
	
	audioManager = preload("res://addons/DialogHelperTool/Game/AudioManager/AudioManager.tscn").instantiate()
	add_child(audioManager)
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(
		func():
			scene_ready = true
			)
	add_child(timer)
	timer.start(1)

	

func save():
	var result = {
		"date": Time.get_datetime_string_from_system(false, true),
		"scene": scene_src_params["scene_name"],
		"timeline": scene_src_params["timeline_name"],
		"state": DialogState.getState(),
		"clickable_background": clickable_background
	}
	var img: Image = get_viewport().get_texture().get_image()
	img.resize(480, 270)
	var data : PackedByteArray = img.save_png_to_buffer()
	result.preview = Marshalls.raw_to_base64(data)
	return result

func setDialogParams(dict: Dictionary):
	background.reset_shaders()
	clickable_background = dict.clickable_background
	choicesBlock.visible = false
	dialogManager.videos_list = dict.videos
	dialogManager.background_list = dict.backgrounds
	dialogManager.character_list = dict.characters
	audioManager.resources = dict.sounds
	dialogManager.timeline = dict.timeline
	if dict.has("current_index"):
		dialogManager.current_index = dict["current_index"]
		dialogManager.deep_index = dict["deep_index"]
	else:
		dialogManager.reset_index()
	scene_root = dict.scene_root
	scene_src_params = dict
	dialogManager.play_next_event()

func set_person_source(obj: String, src):
	persons.set_person_source(obj, src)

func set_person_visible(obj: String, v: bool):
	persons.set_person_visible(obj, v)
		
func person_animation(obj: String, type: String = "dir", animation: String = "RESET", time: float = 1.0, backwards: bool = false):
	persons.person_animation(obj, type, animation, time, backwards)

	
func _process(_delta):
	pass

func _on_dialog_manager_end():
	textArea.resetCharacter()
	textArea.text = ""
	if DialogState.gs("_next_timeline") != "":
		choicesBlock.visible = false
		dialogManager.timeline = scene_root + "timelines/" + DialogState.gs("_next_timeline") + ".json"
		dialogManager.reset_index()
		print("end")
		dialogManager.play_next_event()
		return
	if DialogState.gs("_next_scene") != "":
		get_tree().change_scene_to_file("res://Scene/Empty.tscn")

func _on_dialog_manager_reset_character():
	textArea.resetCharacter()

func _on_dialog_manager_update_character(portrait, character_name):
	textArea.setCharacter(portrait, character_name)

func _on_dialog_manager_update_text(text):
	textArea.text = text

func _on_text_area_on_next():
	if !scene_ready:
		return
	if !clickable_background && textArea.text == "":
		return
	if !choice_mode():
		dialogManager.play_next_event()

func _on_dialog_manager_set_background(res, has_background, params):
	background.set_background(res, has_background, params)

func _on_background_gui_input(event):
	if !scene_ready:
		return
	if event is InputEventMouseButton \
		&& clickable_background \
		&& !choice_mode() \
		&& event.button_index == MOUSE_BUTTON_LEFT \
		&& event.pressed == true:
			
		print("bc clicked")
		dialogManager.play_next_event()

func _on_dialog_manager_set_background_clickable(value):
	clickable_background = value

func _on_dialog_manager_play_sound(_name, channel, loop, bus, volume, fade):
	audioManager.play(_name, channel, loop, bus, volume, fade)

func _on_dialog_manager_stop_sound(channel):
	audioManager.stop(channel)

func _on_dialog_manager_show_choices(data):
	if !data.has("scene"):
		choicesBlock.set_choices(data.choices)
		choicesBlock.visible = true
	else:
		if choiceSceneChild:
			choiceSceneChild.get_parent().remove_child(choiceSceneChild)
			choiceSceneChild.queue_free()
			choiceSceneChild = null
		choiceSceneChild = load(data.scene).instantiate()
		choiceSceneContainer.add_child(choiceSceneChild)
		choiceSceneChild.choices = data
		choiceSceneChild.connect("make_choice", scene_make_choice)
		
func scene_make_choice(id: String):
	dialogManager.make_choice(id, id)
	if !dialogManager.is_choice:
		choicesBlock.visible = false
		choiceSceneChild.get_parent().remove_child(choiceSceneChild)
		choiceSceneChild.queue_free()
		choiceSceneChild = null
		
func choice_mode():
	return choicesBlock.visible || choiceSceneChild

func _on_choices_block_choice_clicked(id, text):
	dialogManager.make_choice(id, text)
	if !dialogManager.is_choice:
		choicesBlock.visible = false

func _on_dialog_manager_play_video(res):
	videoPlayer.visible = true
	videoPlayer.player.stop()
	videoPlayer.player.reset_image()
	videoPlayer.player.stream = res
	videoPlayer.player.play()

func _on_dialog_manager_stop_video():
	videoPlayer.visible = false
	videoPlayer.player.stop()
	videoPlayer.player.reset_image()
