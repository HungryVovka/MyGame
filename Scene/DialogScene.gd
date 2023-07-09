extends Control

@onready var textArea = $MarginContainer/TextArea
@onready var dialogManager = $DialogManager
@onready var audioManager = $AudioManager
@onready var background = $Background
@onready var choicesBlock = $ChoisesBlock
@onready var videoPlayer = $PanelContainer/VideoStreamPlayer
@onready var videoPanel = $PanelContainer

@export var clickable_background = false

@export_file("*.json") var fn: String


@onready var persons: Dictionary = {
	"left": $PersonLeft,
	"middle-left": $PersonMiddleLeft,
	"middle": $PersonMiddle,
	"middle-right": $PersonMiddleRight,
	"right": $PersonRight
}

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

func save():
	var result = {
		"date": Time.get_datetime_string_from_system(false, true),
		"scene": scene_src_params["scene_name"],
		"timeline": scene_src_params["timeline_name"],
		"state": DialogState.getState(),
		"current_index": dialogManager.last_event.current_index,
		"deep_index": dialogManager.last_event.deep_index,
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
	print("dialog params")
	dialogManager.play_next_event()

func set_person_source(obj: String, src):
	if persons.has(obj):
		persons[obj].setSource(src)

func set_person_visible(obj: String, v: bool):
	if persons.has(obj):
		persons[obj].setVisible(v)
		
func person_animation(obj: String, type: String = "dir", animation: String = "RESET", time: float = 1.0, backwards: bool = false):
	if persons.has(obj):
		match type:
			"dir":
				persons[obj].play_dir(animation, time, backwards)
			"fade":
				persons[obj].play_fade(time, backwards)
	pass

func _ready():
	choicesBlock.visible = false
	dialogManager.timeline = fn
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(
		func():
			scene_ready = true
			)
	add_child(timer)
	timer.start(1)
	
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
	if !choicesBlock.visible:
		dialogManager.play_next_event()

func _on_dialog_manager_set_background(res, has_background, params):
	background.set_background(res, has_background, params)

func _on_background_gui_input(event):
	if !scene_ready:
		return
	if event is InputEventMouseButton \
		&& clickable_background \
		&& !choicesBlock.visible \
		&& event.button_index == MOUSE_BUTTON_LEFT \
		&& event.pressed == true:
		dialogManager.play_next_event()

func _on_dialog_manager_set_background_clickable(value):
	clickable_background = value

func _on_dialog_manager_play_sound(_name, channel, loop, bus, volume, fade):
	audioManager.play(_name, channel, loop, bus, volume, fade)

func _on_dialog_manager_stop_sound(channel):
	audioManager.stop(channel)

func _on_dialog_manager_show_choices(data):
	choicesBlock.set_choices(data)
	choicesBlock.visible = true

func _on_choices_block_choice_clicked(id, text):
	dialogManager.make_choice(id, text)
	if !dialogManager.is_choice:
		choicesBlock.visible = false

func _on_dialog_manager_play_video(res):
	videoPanel.visible = true
	videoPlayer.stop()
	videoPlayer.reset_image()
	videoPlayer.stream = res
	videoPlayer.play()

func _on_dialog_manager_stop_video():
	videoPanel.visible = false
	videoPlayer.stop()
	videoPlayer.reset_image()
