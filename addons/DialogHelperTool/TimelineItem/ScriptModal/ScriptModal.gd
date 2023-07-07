@tool
extends Control

var child: Node
@onready var modal = $Modal
@export var sender: Node
@export var text: String: set = setText, get = getText
@export var popup_size: Vector2: set = setPopupSize, get = getPopupSize

signal success(data: Dictionary)
signal back_clicked()

var _is_ready = false

func _ready():
	var editor_class = preload("res://addons/DialogHelperTool/TimelineItem/ScriptModal/Editor/Editor.tscn")
	child = editor_class.instantiate()
	modal.child = child
	_is_ready = true
	
func close_window_no_data():
	hide_modal()
	back_clicked.emit()

func close_window(data: Dictionary = {"script": ""}):
	hide_modal()
	success.emit(data)
	
func setText(s: String):
	if !_is_ready:
		await self.ready
	if child:
		child.text = s
	
func getText() -> String:
	if !_is_ready:
		return ""
	return child.text
	
func setPopupSize(v: Vector2):
	if !_is_ready:
		await self.ready
	modal.popup_size = v
	
func getPopupSize() -> Vector2:
	if !_is_ready:
		await self.ready
	return modal.popup_size
	
func show_modal():
	visible = true
	modal.show_animation()
	
func hide_modal():
	modal.hide_animation()

func _on_modal_was_hidden():
	self.visible = false
