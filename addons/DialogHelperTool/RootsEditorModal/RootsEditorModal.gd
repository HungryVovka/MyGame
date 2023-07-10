@tool
extends Control

var child: Node
@onready var modal = $Modal
@export var src: Dictionary = {}: set = setSource
@export var popup_size: Vector2 = Vector2(1.0, 1.0): set = setPopupSize, get = getPopupSize

signal success(data: Dictionary)
signal back_clicked()
signal root_name_changed(old, new)

var _is_ready = false

func setSource(data: Dictionary):
	if !_is_ready:
		await self.ready
	child.source = data

func _ready():
	var root_item_class = preload("res://addons/DialogHelperTool/RootsEditorModal/RootsEditor/RootsEditor.tscn")
	child = root_item_class.instantiate()
	modal.child = child
	child.connect("root_name_changed", _on_root_name_changed)
	_is_ready = true
	
func _on_root_name_changed(old, new):
	root_name_changed.emit(old, new)
	
func close_window_no_data():
	hide_modal()
	back_clicked.emit()

func close_window(data: Dictionary = {}):
	hide_modal()
	success.emit(data)
	
func setPopupSize(v: Vector2):
	if !_is_ready:
		await self.ready
	modal.popup_size = v
	popup_size = v
	
func getPopupSize() -> Vector2:
	return popup_size
	
func show_modal():
	visible = true
	modal.show_animation()
	
func hide_modal():
	modal.hide_animation()

func _on_modal_was_hidden():
	self.visible = false

