@tool
extends Control

@export var text: String = "": set = setText
@export var button_pressed: bool = false: set = setPressed
@onready var label = $Button/Label
@onready var button = $Button

signal pressed()
signal toggled(v)
signal motion_pass(event)
signal on_mouse_entered()
signal on_mouse_left()

func setText(s):
	if !is_node_ready():
		await ready
	label.text = s
	text = s
	
func setPressed(v):
	if !is_node_ready():
		await ready
	button.button_pressed = v
	button_pressed = v

func _on_button_toggled(is_pressed):
	button_pressed = is_pressed
	if is_pressed:
		pressed.emit(is_pressed)
	toggled.emit(is_pressed)

func _on_button_gui_input(event):
	if event is InputEventMouseMotion:
		var ev: InputEventMouseMotion = event.duplicate()
		ev.position += position
		motion_pass.emit(ev)

func _on_button_mouse_entered():
	on_mouse_entered.emit()

func _on_button_mouse_exited():
	on_mouse_left.emit()
