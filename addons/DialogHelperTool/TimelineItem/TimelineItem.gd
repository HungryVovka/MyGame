@tool
extends Control

@onready var event_id = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/EventId
@onready var jump_to = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/JumpDropdown
@onready var jump_to_opt = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/JumpDropdown/OptionButton

@onready var character = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CharacterDropdown
@onready var character_opt = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CharacterDropdown/OptionButton
@onready var character_checkbox = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CharacterCheckbox

@onready var timer_spinbox = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CenterContainer3/TimerSpinbox
@onready var timer_checkbox = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TimerCheckbox

@export var control_color_inactive: Color = Color("000030ef")
@export var control_color_active: Color = Color(0.4, 1.0, 0.4, 0.7)

@export var data: Dictionary = {}: set = setData
@export var backgrounds: Dictionary = {}
@export var sounds: Dictionary = {}
@export var videos: Dictionary = {}

@export var bus_list: Array[String] = []

@export var selected: bool = false: set = setSelected
@onready var panel = $PanelContainer

@export var context: Dictionary = {"ids": [], "characters": []}: set = setContext
var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()

@onready var textButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TextButton
@onready var backgroundsButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BackgroundButton
@onready var soundsButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SoundsButton
@onready var scriptButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ScriptButton
@onready var statsButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/StatsButton

@onready var textField = $PanelContainer/MarginContainer/VBoxContainer/TextField/Panel/HBoxContainer/Text
@onready var audioField = $PanelContainer/MarginContainer/VBoxContainer/AudioField
@onready var backgroundField = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField

@onready var soundCombobox = $PanelContainer/MarginContainer/VBoxContainer/AudioField/Panel/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PlaySound/SoundCombobox
@onready var soundBusCombobox = $PanelContainer/MarginContainer/VBoxContainer/AudioField/Panel/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PlaySound/SoundBusCombobox
@onready var playSoundChannel = $PanelContainer/MarginContainer/VBoxContainer/AudioField/Panel/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PlaySound/PlaySoundChannel
@onready var soundVolume = $PanelContainer/MarginContainer/VBoxContainer/AudioField/Panel/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PlaySound/SoundVolume
@onready var soundFade = $PanelContainer/MarginContainer/VBoxContainer/AudioField/Panel/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PlaySound/SoundFade
@onready var stopSoundChannel = $PanelContainer/MarginContainer/VBoxContainer/AudioField/Panel/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/StopSound/StopChannel
@onready var playSoundCheckbox = $PanelContainer/MarginContainer/VBoxContainer/AudioField/Panel/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PlaySound/PlaySoundCheckbox
@onready var stopSoundCheckbox = $PanelContainer/MarginContainer/VBoxContainer/AudioField/Panel/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/StopSound/StopSoundCheckbox

@onready var backgroundCheckbox = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField/Panel/HBoxContainer/BackgroundCheckbox
@onready var backgroundName = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField/Panel/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/BackgroundName
@onready var backgroundVideoName = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField/Panel/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/VideoName
@onready var backgroundClickable = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField/Panel/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GridContainer/Clickable
@onready var backgroundTransitionButton = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField/Panel/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/TransitionButton
@onready var backgroundPreview = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField/Panel/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/HBoxContainer/Preview
@onready var backgroundBlock = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField/Panel/HBoxContainer/PanelContainer/MarginContainer/MarginContainer


var texHideTimer: Timer
var tex: TextureRect
var scale_coef: float = 1.0

signal was_selected(obj)
signal show_script(sender, text)
signal show_transitions(sender, data)
signal id_created()


var _is_ready = false
var _data_ready = false
func _ready():
	_is_ready = true
	
	texHideTimer = Timer.new()
	texHideTimer.wait_time = 0.1
	texHideTimer.one_shot = true
	texHideTimer.timeout.connect(func(): if tex && tex.visible: tex.visible = false)
	
func rescale_fonts(coef: float):
	if !_is_ready:
		await self.ready
	var settings : LabelSettings = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LeftSpace/Label3.label_settings.duplicate()
	settings.font_size *= coef
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/Label2.label_settings = settings
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LeftSpace/Label3.label_settings = settings
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Label2.label_settings = settings
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label.label_settings = settings
	var v = int($PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/EventId.get_theme_font_size("font_size") * coef)
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/EventId.add_theme_font_size_override("font_size", v)
	
	character.setScale(coef)
	jump_to.setScale(coef)

	textButton.setScale(coef)
	backgroundsButton.setScale(coef)
	scriptButton.setScale(coef)
	statsButton.setScale(coef)
	soundsButton.setScale(coef)
	
	var oldSize: Vector2 = $PanelContainer/MarginContainer/VBoxContainer/TextField.custom_minimum_size
	$PanelContainer/MarginContainer/VBoxContainer/TextField.custom_minimum_size = Vector2(oldSize.x, oldSize.y * coef)
	
	oldSize = $PanelContainer/MarginContainer/VBoxContainer/AudioField.custom_minimum_size
	$PanelContainer/MarginContainer/VBoxContainer/AudioField.custom_minimum_size = Vector2(oldSize.x, oldSize.y * coef)
	
	oldSize = $PanelContainer/MarginContainer/VBoxContainer/BackgroundField.custom_minimum_size
	$PanelContainer/MarginContainer/VBoxContainer/BackgroundField.custom_minimum_size = Vector2(oldSize.x, oldSize.y * coef)
	
	soundCombobox.setScale(coef)
	soundBusCombobox.setScale(coef)
	
	backgroundName.setScale(coef)
	backgroundVideoName.setScale(coef)
	backgroundClickable.setScale(coef)
	
	scale_coef = coef

func setContext(data):
	if !_is_ready:
		await self.ready
	context = data
	var jump_to_data: Array[String] = fixTypes([""] + data.ids + ["/"] + data.roots)
	jump_to.items = jump_to_data
	if !jump_to_data.has(jump_to.text) && jump_to.text.begins_with("/"):
		jump_to.text = ""
	character.items = fixTypes(data.characters)
	
func setSelected(v):
	var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color("0000034e") if !v else Color("4488ff40")
	panel.add_theme_stylebox_override("panel", stylebox)
	selected = v

func setData(src: Dictionary):
	if !_is_ready:
		await self.ready
	data = src
	
	if src.has("id"):
		event_id.text = src.id
		switch_control_style(event_id, true)
	if src.has("character"):
		character.text = src.character
	character_checkbox.button_pressed = src.has("character")
	character.enabled = src.has("character")
	if src.has("jump_to"):
		jump_to.text = src.jump_to
	else:
		jump_to.text = ""
	if src.has("timer"):
		timer_spinbox.value = src.timer
	else:
		timer_spinbox.value = 1.0
	timer_checkbox.button_pressed = src.has("timer")
	textField.text = src.text
	
	soundCombobox.items = fixTypes([""] + sounds.keys())
	soundBusCombobox.items = fixTypes([""] + bus_list)
	
	renderAudio()
	renderBackground()
	updateButtons()
	
	_data_ready = true
	
func renderAudio():
	playSoundCheckbox.button_pressed = data.has("play_sound")
	stopSoundCheckbox.button_pressed = data.has("stop_sound")
	if data.has("play_sound"):
		soundCombobox.text = data.play_sound.name
		playSoundChannel.text = data.play_sound.channel
		soundBusCombobox.text = data.play_sound.bus if data.play_sound.has("bus") else ""
		soundVolume.value = data.play_sound.volume if data.play_sound.has("volume") else 1.0
		soundFade.value = data.play_sound.fade if data.play_sound.has("fade") else 0.0
	if data.has("stop_sound"):
		stopSoundChannel.text = data.stop_sound
		
func renderBackground():
	backgroundName.items = fixTypes(["", "Ignore"] + backgrounds.keys())
	backgroundVideoName.items = fixTypes(["", "Ignore"] + videos.keys())
	backgroundClickable.items = fixTypes(["", "True", "False"])
	backgroundCheckbox.button_pressed = data.has("background")
	_on_background_checkbox_toggled(data.has("background"))
	if data.has("background"):
		backgroundName.text = data.background.name if data.background.has("name") else "Ignore"
		backgroundVideoName.text = data.background.video if data.background.has("video") else "Ignore"
		if data.background.has("clickable"):
			backgroundClickable.text = "True" if data.background.clickable else "False"
		else:
			backgroundClickable.text = ""
		backgroundPreview.texture = backgrounds[data.background.name] if data.background.has("name") && backgrounds.has(data.background.name) else null
		backgroundTransitionButton.button_pressed = data.background.has("transition")
		if data.background.has("transition"):
			backgroundTransitionButton.text = "TRANSITION\n" + transition_to_text(data.background.transition)
		
		
func updateButtons():	
	textButton.setActive(data.text != "")
	backgroundsButton.setActive(data.has("background"))
	soundsButton.setActive(data.has("play_sound") || data.has("stop_sound"))
	scriptButton.setActive(data.has("script"))
	statsButton.setActive(data.has("stats"))
	if data.has("background") && data.background.has("transition"):
		backgroundTransitionButton.text = "TRANSITION\n" + transition_to_text(data.background.transition)
		backgroundTransitionButton.button_pressed = data.background.has("transition")
	else:
		backgroundTransitionButton.text = "TRANSITION"
		backgroundTransitionButton.button_pressed = false

func switch_control_style(control, is_active):
	if (!control): 
		return 
	var stylebox: StyleBoxFlat = control.get_theme_stylebox("normal").duplicate()
	stylebox.shadow_color = control_color_active if is_active else control_color_inactive
	control.add_theme_stylebox_override("normal", stylebox)

func _on_event_id_text_changed(new_text: String):
	switch_control_style(event_id, new_text != "")
	if !_data_ready:
		return
	if new_text != "":
		data["id"] = new_text
		id_created.emit()
	else:
		data.erase("id")
		id_created.emit()

func _on_dropdownbox_item_selected(text):
	switch_control_style(jump_to_opt, text != "")
	if !_data_ready:
		return
	if text != "":
		data["jump_to"] = text
	else:
		data.erase("jump_to")


func _on_character_dropdown_item_selected(text):
	switch_control_style(character_opt, text != "")
	if !_data_ready:
		return
	data["character"] = text


func _on_character_checkbox_toggled(button_pressed):
	character.enabled = button_pressed
	if !_data_ready:
		return
	if button_pressed:
		data["character"] = character.text
	else:
		data.erase("character")


func _on_timer_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	if button_pressed:
		data["timer"] = timer_spinbox.value
	else:
		data.erase("timer")


func _on_timer_spinbox_value_changed(value):
	if !_data_ready:
		return
	data["timer"] = value

func _on_panel_container_gui_input(event):
	if event is InputEventMouseMotion:
		if data.has("background") && data.background.has("name") && backgrounds.has(data.background.name):
			if !tex:
				tex = TextureRect.new()
				add_child(tex)
				tex.set_size(Vector2(1920.0/6.0*scale_coef, 1080.0/6.0*scale_coef))
				tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				tex.stretch_mode = TextureRect.STRETCH_SCALE
				tex.clip_contents = true
				tex.z_index = 10
				tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
				tex.texture = backgrounds[data.background.name]
			tex.position = event.position
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		selected = !selected
		if selected:
			was_selected.emit(self)
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
		move_up()
			
func move_up():
	get_parent().move_child(self, get_index() - 1)


func _on_panel_container_mouse_exited():
	if tex: 
		tex.visible = false


func _on_panel_container_mouse_entered():
	if tex && tex.visible == false:
		tex.visible = true

func fixTypes(data: Array = []) -> Array[String]:
	var result: Array[String] = []
	result.assign(data)
	return result


func _on_text_button_toggled(pressed):
	var height = 80*scale_coef + 8
	custom_minimum_size += Vector2(0, height if pressed else -height)
	$PanelContainer/MarginContainer/VBoxContainer/TextField.visible = pressed


func _on_text_text_changed():
	data["text"] = textField.text
	updateButtons()


func _on_sounds_button_toggled(pressed):
	var height = 100*scale_coef + 8
	custom_minimum_size += Vector2(0, height if pressed else -height)
	$PanelContainer/MarginContainer/VBoxContainer/AudioField.visible = pressed
	
func _on_background_button_toggled(pressed):
	var height = 110*scale_coef + 8
	custom_minimum_size += Vector2(0, height if pressed else -height)
	$PanelContainer/MarginContainer/VBoxContainer/BackgroundField.visible = pressed

func _on_sound_combobox_item_selected(text):
	if data.has("play_sound"):
		if text != "":
			data.play_sound["name"] = text
		else:
			data.play_sound.erase("name")
	updateButtons()

func _on_play_sound_channel_text_changed(new_text):
	if data.has("play_sound"):
		data.play_sound["channel"] = new_text
	updateButtons()

func _on_sound_bus_combobox_item_selected(text):
	if data.has("play_sound"):
		if text != "":
			data.play_sound["bus"] = text
		else:
			data.play_sound.erase("bus")
	updateButtons()

func _on_sound_volume_value_changed(value):
	if data.has("play_sound"):
		if value != 1.0:
			data.play_sound["volume"] = value
		else:
			data.play_sound.erase("volume")
	updateButtons()


func _on_sound_fade_value_changed(value):
	if data.has("play_sound"):
		if value != 0.0:
			data.play_sound["fade"] = value
		else:
			data.play_sound.erase("fade")
	updateButtons()


func _on_play_sound_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	if button_pressed:
		if !data.has("play_sound"):
			data.play_sound = {}
		_on_sound_combobox_item_selected(soundCombobox.text)
		_on_play_sound_channel_text_changed(playSoundChannel.text)
		_on_sound_bus_combobox_item_selected(soundBusCombobox.text)
		_on_sound_volume_value_changed(soundVolume.value)
		_on_sound_fade_value_changed(soundFade.value)
	else:
		data.erase("play_sound")
	updateButtons()

func _on_stop_channel_text_changed(new_text):
	if new_text != "":
		data["stop_channel"] = new_text
	else:
		data.erase("stop_channel")
	updateButtons()

func _on_stop_sound_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	if button_pressed:
		_on_stop_channel_text_changed(stopSoundChannel.text)
	else:
		data.erase("stop_sound")
	updateButtons()

func _on_script_button_toggled(pressed):
	if pressed:
		show_script.emit(self, data["script"] if data.has("script") else "func start(_dialog, _event):
	pass
	
func condition(_dialog, _event):
	return true")

func scriptPopupHidden():
	scriptButton.pressed = false
	updateButtons()
	
func transitionsPopupHidden():
	updateButtons()
	
func updateScriptText(text):
	if text != "":
		data["script"] = text
	else:
		data.erase("script")
	updateButtons()

func _on_transition_button_pressed():
	if data.has("background"):
		show_transitions.emit(self, data.background)

func _on_background_checkbox_toggled(button_pressed):
	if !button_pressed:
		data.erase("background")
	else:
		if _data_ready:
			data["background"] = {}
			if backgroundName.text != "Ignore":
				data.background.name = backgroundName.text
			if backgroundVideoName.text != "Ignore":
				data.background.video = backgroundVideoName.text
			if backgroundClickable.text != "":
				data.background.clickable = backgroundClickable.text
			#load data from transition
	backgroundBlock.visible = !button_pressed
	updateButtons()

func _on_background_name_item_selected(text):
	if _data_ready:
		if text == "Ignore":
			data.background.erase("name")
		else:
			data.background.name = text
		backgroundPreview.texture = backgrounds[data.background.name] if data.background.has("name") && backgrounds.has(data.background.name) else null

func _on_video_name_item_selected(text):
	if _data_ready:
		if text == "Ignore":
			data.background.erase("video")
		else:
			data.background.video = text

func _on_clickable_item_selected(text):
	if _data_ready:
		if text == "":
			data.background.erase("clickable")
		else:
			data.background.clickable = true if text == "True" else false
			
func transition_to_text(transition: Dictionary) -> String:
	var result = "[ "
	if JSONHelper.gb(transition, ["swipe_mode_h", "swipe_mode_v"]):
		result += "swipe "
	if JSONHelper.gb(transition, ["scale_mode"]):
		result += "scale "
	if JSONHelper.gb(transition, ["shake_mode"]):
		result += "shake "
	if JSONHelper.gb(transition, ["blend_mode"]):
		result += "blend "
	if JSONHelper.gb(transition, ["fade_to", "fade_from"]):
		result += "fade "
	if JSONHelper.gb(transition, ["slide_h", "slide_v"]):
		result += "slide "
	if JSONHelper.gb(transition, ["curtain_h", "curtain_v"]):
		result += "curtain "
	return result + "]"
