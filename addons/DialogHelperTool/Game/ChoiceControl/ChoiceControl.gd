extends Control

@export var choice_id: String = ""
@export var hover_color: Color = Color.WHITE
@export var pressed_color: Color = Color(0.8, 0.8, 1, 1.0)


var choice_type: String = "CHOICE_CONTROL"
var dialog_tool_type: String = "CHOICE_CONTROL"
var entered : bool = false
signal pressed(id)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				modulate = pressed_color
			else:
				modulate = hover_color if entered else Color.WHITE
				pressed.emit(choice_id)

func _on_mouse_entered():
	entered = true
	modulate = hover_color


func _on_mouse_exited():
	entered = false
	modulate = Color.WHITE
