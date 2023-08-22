extends Control
signal on_next()

func _on_gui_input(event):
	if event is InputEventMouseButton \
		&& event.button_index == MOUSE_BUTTON_LEFT \
		&& event.pressed == true:
		on_next.emit()
