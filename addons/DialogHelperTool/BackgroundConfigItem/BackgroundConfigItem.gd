@tool
extends Control

@onready var tex = $PanelContainer/TextureRect
@onready var line = $PanelContainer/LineEdit

@export var source: Dictionary
@export var element_id: String
@export var selected: bool = false

var preload_settings: Dictionary

signal on_changed()

func _ready():
	load_settings()
	
func load_settings():
	source = preload_settings.dict
	element_id = preload_settings.key
	
	if source.has(element_id) && source[element_id] != "":
		tex.texture = load(source[element_id])
	line.text = element_id

func set_source(dict, key):
	preload_settings.dict = dict
	preload_settings.key = key
	if tex && line:
		load_settings()

func _on_texture_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			selected = !selected
			apply_selected()
			
func apply_selected():
	if !selected:
		modulate = Color.WHITE
	else:
		modulate = Color(1.0, 0.4, 0.4, 1.0)


func _on_line_edit_text_changed(new_text):
	if !source.has(new_text):
		var value = source[element_id]
		source[new_text] = value
		source.erase(element_id)
		element_id = new_text
		on_changed.emit()
