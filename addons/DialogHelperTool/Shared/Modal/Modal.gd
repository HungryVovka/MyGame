@tool
extends Control

@export var popup_size: Vector2 = Vector2(1.0, 1.0): set = setPopupSize
@export var child: Node = null: set = setChild
@export var background_color : Color = Color.BLACK: set = setColor
@export var popup_time: float = 1.0

@export var init_blur: float = 0.0
@export var full_blur: float = 2.5
@export var blur: float = 0.0: set = setBlur, get = getBlur


@onready var margin_container: MarginContainer = $Panel/MarginContainer
@onready var modal = $"."
@onready var container: PanelContainer = $Panel/MarginContainer/PanelContainer
@onready var color_rect: ColorRect = $Panel/MarginContainer/PanelContainer/ColorRect
@onready var back_panel = $Panel

signal success(data)
signal canceled(data)
signal back_clicked()
signal was_hidden()

var animation_tween: Tween

var _is_ready = false

func _ready():
	_is_ready = true
	modulate = Color(1, 1, 1, 0)
	
func setBlur(v: float):
	back_panel.material.set_shader_parameter("blur_amount", v)
	blur = v

func getBlur():
	return blur
	

func show_animation():
	if animation_tween:
		animation_tween.kill()
		animation_tween = null
	animation_tween = get_tree().create_tween()
	animation_tween.set_parallel(true)
	animation_tween.tween_property(self, "modulate", Color.WHITE, popup_time).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	animation_tween.tween_property(self, "blur", full_blur, popup_time).set_trans(Tween.TRANS_SINE)
	
func hide_animation():
	if animation_tween:
		animation_tween.kill()
		animation_tween = null
	animation_tween = get_tree().create_tween()
	animation_tween.set_parallel(true)
	animation_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), popup_time).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	animation_tween.tween_property(self, "blur", init_blur, popup_time).set_trans(Tween.TRANS_CIRC)
	animation_tween.set_parallel(false)
	animation_tween.tween_callback(hide_callback)
	
func hide_callback():
	was_hidden.emit()
	
func setColor(clr: Color):
	if !_is_ready:
		await self.ready
	color_rect.color = clr
	background_color = clr

func setPopupSize(src: Vector2):
	if !_is_ready:
		await self.ready
	popup_size = src
	var margin_x = (1.0 - src.x) / 2.0 * size.x
	var margin_y = (1.0 - src.y) / 2.0 * size.y
	margin_container.add_theme_constant_override("margin_left", margin_x)
	margin_container.add_theme_constant_override("margin_right", margin_x)
	margin_container.add_theme_constant_override("margin_top", margin_y)
	margin_container.add_theme_constant_override("margin_bottom", margin_y)
	
	var stylebox: StyleBoxFlat = container.get_theme_stylebox("panel").duplicate()
	stylebox.shadow_size = min(margin_x, margin_y)
	container.add_theme_stylebox_override("panel", stylebox)

func setChild(c: Node):
	if child:
		child.queue_free()
		container.remove_child(child)
	child = c
	if child:
		container.add_child(c)
		if child.has_signal("success"):
			child.connect("success", on_child_success)
		if child.has_signal("canceled"):
			child.connect("canceled", on_child_canceled)
		
func on_child_success(data: Dictionary = {}):
	success.emit(data)
func on_child_canceled(data: Dictionary = {}):
	canceled.emit(data)


func _on_margin_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			back_clicked.emit()
			
