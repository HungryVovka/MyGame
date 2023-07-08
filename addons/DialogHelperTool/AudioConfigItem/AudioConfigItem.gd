@tool
extends Control

@onready var line = $PanelContainer/LineEdit
@export var source: Dictionary
@export var element_id: String

@export var selected: bool = false
@export var selected_color: Color = Color(1.0, 0.4, 0.4, 1.0)
@export var default_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var preload_settings: Dictionary

signal on_changed()

func _ready():
	load_settings()
	
func load_settings():
	if preload_settings.has("dict") || preload_settings.has("key"):
		source = preload_settings.dict
		element_id = preload_settings.key
		line.text = element_id

func set_source(dict, key):
	preload_settings.dict = dict
	preload_settings.key = key
	if line:
		load_settings()
		
func _on_texture_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			selected = !selected
			apply_selected()
			
func apply_selected():
	if !selected:
		modulate = default_color
	else:
		modulate = selected_color

func _on_line_edit_text_changed(new_text):
	if !source.has(new_text):
		var value = source[element_id]
		source[new_text] = value
		source.erase(element_id)
		element_id = new_text
		on_changed.emit()
