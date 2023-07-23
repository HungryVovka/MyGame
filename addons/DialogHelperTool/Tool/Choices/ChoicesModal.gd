@tool
extends Control

var child: Node
@onready var modal = $Modal
@export var sender: Node
@export var src: Dictionary = {}: set = setSource
@export var popup_size: Vector2 = Vector2(1.0, 1.0): set = setPopupSize, get = getPopupSize

signal success(data: Dictionary)
signal back_clicked()
signal create_root(name)
signal open_root(name)

var _is_ready = false

func on_create_root(name):
	create_root.emit(name)
	
func on_open_root(name):
	open_root.emit(name)
	close_window_no_data()

func setSource(data: Dictionary):
	if !_is_ready:
		await self.ready
	child.clean()
	child.src = data

func setRoot(s):
	if !_is_ready:
		await self.ready
	if child:
		child.root_prefix = s
		
func setRootList(l):
	if !_is_ready:
		await self.ready
	if child:
		child.roots = l

func _ready():
	var item_class = preload("res://addons/DialogHelperTool/Tool/Choices/ChoicesConfig/ChoicesConfig.tscn")
	child = item_class.instantiate()
	child.connect("create_root", on_create_root)
	child.connect("open_root", on_open_root)
	modal.child = child
	_is_ready = true
	
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

