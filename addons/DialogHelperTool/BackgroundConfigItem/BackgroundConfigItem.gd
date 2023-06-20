@tool
extends Control

@onready var tex = $PanelContainer/TextureRect
@onready var line = $PanelContainer/LineEdit

@export var source: Dictionary
@export var element_id: String
@export var selected: bool = false
@export var selected_color: Color = Color(1.0, 0.4, 0.4, 1.0)
@export var default_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var preload_settings: Dictionary

var _is_ready: bool = false

signal on_changed()

func _ready():
	_is_ready = true

func set_source(dict, key, store):
	if !_is_ready:
		await self.ready
	source = dict
	element_id = key
	if source.has(element_id) && source[element_id] != "":
		tex.texture = store[element_id]
	line.text = element_id

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
