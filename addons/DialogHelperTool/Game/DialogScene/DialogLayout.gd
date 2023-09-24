extends Control

@onready var textArea
var dialogManager: DialogManager
var audioManager: AudioManager
var downloader: DialogResourceLoader = DialogResourceLoader.new()
@onready var backgrounds = []
@onready var choicesBlocks = []
@onready var videoPlayers = []
@onready var persons = []


@export var choiceSceneContainer: Node
@export var backgroundSceneContainer: Node

@export var clickable_background = false

@export_file("*.json") var fn: String
@export_file("*.tscn") var loading_scene

var choiceSceneChild: Node
var customBackgroundChild: Node

var scene_root = ""
var scene_ready = false
var scene_src_params = {}

var LayoutManager = preload("res://addons/DialogHelperTool/Shared/LayoutManager.gd").new()

var typeD : Dictionary = {
	"date": "string",
	"scene": "string",
	"timeline": "string",
	"preview": "string",
	"state": "dict",
}

func extractManagers() -> Dictionary:
	dialogManager.disconnect("end", on_dialog_manager_end)
	dialogManager.disconnect("personAnimation", person_animation)
	dialogManager.disconnect("personSource", set_person_source)
	dialogManager.disconnect("personVisible", set_person_visible)
	dialogManager.disconnect("playSound", on_dialog_manager_play_sound)
	dialogManager.disconnect("playVideo", on_dialog_manager_play_video)
	dialogManager.disconnect("resetCharacter", on_dialog_manager_reset_character)
	dialogManager.disconnect("setBackground", on_dialog_manager_set_background)
	dialogManager.disconnect("setCustomBackground", on_dialog_manager_set_custom_background)
	dialogManager.disconnect("setBackgroundClickable", on_dialog_manager_set_background_clickable)
	dialogManager.disconnect("showChoices", on_dialog_manager_show_choices)
	dialogManager.disconnect("stopSound", on_dialog_manager_stop_sound)
	dialogManager.disconnect("stopVideo", on_dialog_manager_stop_video)
	dialogManager.disconnect("updateCharacter", on_dialog_manager_update_character)
	dialogManager.disconnect("updateText", on_dialog_manager_update_text)
	
	
	remove_child(dialogManager)
	remove_child(audioManager)
	
	return {
		"audioManager": audioManager,
		"dialogManager": dialogManager
	}

func embedManagers(src: Dictionary):
	audioManager = src.audioManager
	dialogManager = src.dialogManager
func _ready():
	connectControls()
	downloader.connect("done", dialogResourcesReady)
	add_child(downloader)
	for c in choicesBlocks:
		c.visible = false
	var dm_is_created = false
	if !dialogManager:
		dialogManager = preload("res://addons/DialogHelperTool/Game/DialogManager/DialogManager.gd").new()
		dm_is_created = true
	add_child(dialogManager)
	dialogManager.get_parent().move_child(dialogManager, 0)
	dialogManager.connect("end", on_dialog_manager_end)
	dialogManager.connect("personAnimation", person_animation)
	dialogManager.connect("personSource", set_person_source)
	dialogManager.connect("personVisible", set_person_visible)
	dialogManager.connect("playSound", on_dialog_manager_play_sound)
	dialogManager.connect("playVideo", on_dialog_manager_play_video)
	dialogManager.connect("resetCharacter", on_dialog_manager_reset_character)
	dialogManager.connect("setBackground", on_dialog_manager_set_background)
	dialogManager.connect("setCustomBackground", on_dialog_manager_set_custom_background)
	dialogManager.connect("setBackgroundClickable", on_dialog_manager_set_background_clickable)
	dialogManager.connect("showChoices", on_dialog_manager_show_choices)
	dialogManager.connect("stopSound", on_dialog_manager_stop_sound)
	dialogManager.connect("stopVideo", on_dialog_manager_stop_video)
	dialogManager.connect("updateCharacter", on_dialog_manager_update_character)
	dialogManager.connect("updateText", on_dialog_manager_update_text)
	
	if dm_is_created:
		dialogManager.timeline = fn
	
	if !audioManager:
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
	
func connectControls():
	backgrounds = LayoutManager.findControlsInChildren(self, "BACKGROUND")
	choicesBlocks = LayoutManager.findControlsInChildren(self, "CHOICES_BLOCK")
	videoPlayers = LayoutManager.findControlsInChildren(self, "VIDEOPLAYER")
	persons = LayoutManager.findControlsInChildren(self, "PERSON_LAYOUT")
	textArea = LayoutManager.findControlsInChildren(self, "TEXT_AREA", true)
	
	for b in backgrounds:
		b.connect("gui_input", _on_background_gui_input)
	for c in choicesBlocks:
		c.connect("choiceClicked", _on_choices_block_choice_clicked)
	if textArea:
		textArea.connect("on_next", _on_text_area_on_next)

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
	if !is_node_ready():
		await ready
	for b in backgrounds:
		b.reset_shaders()
	clickable_background = dict.clickable_background
	for c in choicesBlocks:
		c.visible = false
	downloadResources(dict)
	scene_src_params = dict
	scene_root = dict.scene_root
	
	dialogManager.character_list = dict.characters
	dialogManager.timeline = dict.timeline


func downloadResources(dict: Dictionary):
	audioManager.resources = dict.sounds
	var fn = dict.videos.values() + dict.backgrounds.values()
	downloader.load(fn)
	
func dialogResourcesReady():
	dialogManager.background_list = scene_src_params.backgrounds
	dialogManager.videos_list = scene_src_params.videos
	for k in scene_src_params.videos.keys():
		dialogManager.videos_resources[k] = downloader.store[scene_src_params.videos[k]]
	for k in scene_src_params.backgrounds.keys():
		dialogManager.background_resources[k] = downloader.store[scene_src_params.backgrounds[k]]
		
	dialogManager.reset_index()
	dialogManager.play_next_event()
	downloader.clear()

func set_person_source(obj: String, src):
	for p in persons:
		p.set_person_source(obj, src)

func set_person_visible(obj: String, v: bool):
	for p in persons:
		p.set_person_visible(obj, v)
		
func person_animation(obj: String, type: String = "dir", animation: String = "RESET", time: float = 1.0, backwards: bool = false):
	for p in persons:
		p.person_animation(obj, type, animation, time, backwards)
	
func _process(_delta):
	pass

func on_dialog_manager_end():
	textArea.resetCharacter()
	textArea.text = ""
	if DialogState.gs("_next_timeline") != "":
		for c in choicesBlocks:
			c.visible = false
		dialogManager.timeline = scene_root + "timelines/" + DialogState.gs("_next_timeline") + ".json"
		dialogManager.reset_index()
		print("end")
		dialogManager.play_next_event()
		return
	if DialogState.gs("_next_scene") != "":
		get_tree().change_scene_to_file(loading_scene)

func on_dialog_manager_reset_character():
	textArea.resetCharacter()

func on_dialog_manager_update_character(portrait, character_name):
	textArea.setCharacter(portrait, character_name)

func on_dialog_manager_update_text(text):
	textArea.text = text



var originalBackgroundContainerChildren: Array[Node] = []

func on_dialog_manager_set_background(res, has_background, params):
	for b in backgrounds:
		b.set_background(res, has_background, params)
	clearCustomBackground()
		
func clearCustomBackground():
	for n in originalBackgroundContainerChildren:
		n.get_parent().remove_child(n)
		backgroundSceneContainer.add_child(n)
	if customBackgroundChild:
		customBackgroundChild.get_parent().remove_child(customBackgroundChild)
		customBackgroundChild.queue_free()
		customBackgroundChild = null
	originalBackgroundContainerChildren.clear()

func on_dialog_manager_set_custom_background(src):
	clearCustomBackground()
	customBackgroundChild = load(src).instantiate()
	customBackgroundChild.set_mouse_filter(MOUSE_FILTER_PASS)
	
	var containerChildren: Array[Node] = backgroundSceneContainer.get_children()
	for n in containerChildren:
		originalBackgroundContainerChildren.push_back(n)
		backgroundSceneContainer.remove_child(n)
		customBackgroundChild.add_child(n)
		
	backgroundSceneContainer.add_child(customBackgroundChild)
	if customBackgroundChild.has_signal("on_next"):
		customBackgroundChild.connect("on_next", func(): dialogManager.play_next_event())

func on_dialog_manager_set_background_clickable(value):
	clickable_background = value

func on_dialog_manager_play_sound(_name, channel, loop, bus, volume, fade):
	audioManager.play(_name, channel, loop, bus, volume, fade)

func on_dialog_manager_stop_sound(channel):
	audioManager.stop(channel)

func on_dialog_manager_show_choices(data):
	if !data.has("scene"):
		for c in choicesBlocks:
			c.set_choices(data.choices)
			c.visible = true
	else:
		if choiceSceneChild:
			choiceSceneChild.get_parent().remove_child(choiceSceneChild)
			choiceSceneChild.queue_free()
			choiceSceneChild = null
		choiceSceneChild = load(data.scene).instantiate()
		choiceSceneContainer.add_child(choiceSceneChild)
		choiceSceneChild.choices = data
		choiceSceneChild.connect("make_choice", scene_make_choice)

func on_dialog_manager_play_video(res):
	for v in videoPlayers:
		v.play(res)

func on_dialog_manager_stop_video():
	for v in videoPlayers:
		v.stop()

func scene_make_choice(id: String):
	dialogManager.make_choice(id, id)
	if !dialogManager.is_choice:
		for c in choicesBlocks:
			c.visible = false
		choiceSceneChild.get_parent().remove_child(choiceSceneChild)
		choiceSceneChild.queue_free()
		choiceSceneChild = null
		
func choice_mode():
	if choiceSceneChild:
		return true
	for c in choicesBlocks:
		if c.visible:
			return true
	return false

func _on_text_area_on_next():
	if !scene_ready:
		return
	if !clickable_background && textArea.text == "":
		return
	if !choice_mode():
		dialogManager.play_next_event()
		
func _on_background_gui_input(event):
	if !scene_ready:
		return false
	if event is InputEventMouseButton \
		&& clickable_background \
		&& !choice_mode() \
		&& event.button_index == MOUSE_BUTTON_LEFT \
		&& event.pressed == true:
		dialogManager.play_next_event()
		return true

func _on_choices_block_choice_clicked(id, text):
	dialogManager.make_choice(id, text)
	if !dialogManager.is_choice:
		for c in choicesBlocks:
			c.visible = false
