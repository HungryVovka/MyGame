@tool
extends Control

@onready var line_id = $Panel/MarginContainer/VBoxContainer/LineId
@onready var line_name = $Panel/MarginContainer/VBoxContainer/LineName
@onready var portrait = $Panel/MarginContainer/TextureRect
@onready var remove_portrait_button = $Panel/MarginContainer/VBoxContainer/RemovePortrait
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
	source = preload_settings.dict
	element_id = preload_settings.key
	line_id.text = element_id
	line_name.text = source[element_id].name
	portrait.texture = load(source[element_id].portrait) if source[element_id].portrait else null
	remove_portrait_button.visible = true if source[element_id].portrait else false
	
func set_source(dict, key):
	preload_settings.dict = dict
	preload_settings.key = key
	if line_id:
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

func _on_line_id_edit_text_changed(new_text):
	if !source.has(new_text):
		var value = source[element_id]
		source[new_text] = value
		source.erase(element_id)
		element_id = new_text
		on_changed.emit()

func _on_line_name_text_changed(new_text):
	source[element_id].name = new_text
	on_changed.emit()

func _on_v_box_container_dropped_data(paths):
	source[element_id].portrait = paths[0]
	portrait.texture = load(paths[0])
	remove_portrait_button.visible = true
	on_changed.emit()

func _on_remove_portrait_pressed():
	source[element_id].portrait = ""
	portrait.texture = null
	remove_portrait_button.visible = false
	on_changed.emit()
