extends Control
signal on_next()

func _on_gui_input(event):
	if event is InputEventMouseButton \
		&& event.button_index == MOUSE_BUTTON_LEFT \
		&& event.pressed == true:
		on_next.emit()

func _on_ui_gui_input(event):
	_on_gui_input(event)

func _on_texture_button_pressed():
	$ui/SubViewport/main.next_texture()


func _ready():
	$TextureRect.texture = $ui/SubViewport.get_texture()
