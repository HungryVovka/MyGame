@tool
extends Control

@onready var event_id = $PanelContainer/MarginContainer/HBoxContainer/EventId
@onready var jump_to = $PanelContainer/MarginContainer/HBoxContainer/JumpDropdown
@onready var jump_to_opt = $PanelContainer/MarginContainer/HBoxContainer/JumpDropdown/OptionButton

@onready var character = $PanelContainer/MarginContainer/HBoxContainer/CharacterDropdown
@onready var character_opt = $PanelContainer/MarginContainer/HBoxContainer/CharacterDropdown/OptionButton
@onready var character_checkbox = $PanelContainer/MarginContainer/HBoxContainer/CharacterCheckbox

@onready var timer_spinbox = $PanelContainer/MarginContainer/HBoxContainer/CenterContainer3/TimerSpinbox
@onready var timer_checkbox = $PanelContainer/MarginContainer/HBoxContainer/TimerCheckbox

@onready var text_control = $PanelContainer/MarginContainer/HBoxContainer/TextPreview
@export var text: String = "": set = setText

@export var control_color_inactive: Color = Color("000030ef")
@export var control_color_active: Color = Color(0.4, 1.0, 0.4, 0.7)

@export var data: Dictionary = {}: set = setData
@export var backgrounds: Dictionary = {}: set = setBackgrounds

@export var selected: bool = false: set = setSelected
@onready var panel = $PanelContainer

@export var context: Dictionary = {"ids": [], "characters": []}: set = setContext
var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()


var texHideTimer: Timer
var tex: TextureRect

signal was_selected(obj)


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
	var settings : LabelSettings = $PanelContainer/MarginContainer/HBoxContainer/LeftSpace/Label3.label_settings.duplicate()
	settings.font_size *= coef
	$PanelContainer/MarginContainer/HBoxContainer/MarginContainer2/Label2.label_settings = settings
	$PanelContainer/MarginContainer/HBoxContainer/LeftSpace/Label3.label_settings = settings
	$PanelContainer/MarginContainer/HBoxContainer/MarginContainer/Label2.label_settings = settings
	$PanelContainer/MarginContainer/HBoxContainer/Label.label_settings = settings
	var v = int($PanelContainer/MarginContainer/HBoxContainer/EventId.get_theme_font_size("font_size") * coef)
	$PanelContainer/MarginContainer/HBoxContainer/EventId.add_theme_font_size_override("font_size", v)
	$PanelContainer/MarginContainer/HBoxContainer/JumpDropdown/LineEdit.add_theme_font_size_override("font_size", v)
	$PanelContainer/MarginContainer/HBoxContainer/CharacterDropdown/LineEdit.add_theme_font_size_override("font_size", v)

	var preview_s : LabelSettings = $PanelContainer/MarginContainer/HBoxContainer/TextPreview.label_settings.duplicate()
	preview_s.font_size *= coef
	$PanelContainer/MarginContainer/HBoxContainer/TextPreview.label_settings = preview_s
	
	
func setText(v):
	text_control.text = v

func setContext(data):
	if !_is_ready:
		await self.ready
	context = data
	jump_to.items = fixTypes(data.ids)
	character.items = fixTypes(data.characters)
	
func setBackgrounds(d):
	backgrounds = d
	
func setSelected(v):
	var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color("0000034e") if !v else Color("0044ff80")
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
	if src.has("text"):
		text_control.text = src.text
	_data_ready = true

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
	else:
		data.erase("id")

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
				tex.set_size(Vector2(1920.0/8.0, 1080.0/8.0))
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
