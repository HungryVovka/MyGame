extends Control

@onready var img = $TextureRect
@onready var label = $Label
@export var default_color = Color(0.6, 0.6, 0.6, 0.7)
@export var over_color = Color(0.8, 0.8, 0.8, 1.0)
@export var pressed_color = Color(1.0, 1.0, 0.8, 1.0)

signal clicked()

var empty_tex = preload("res://Resources/1Main/GUI/empty_slot.png")

func _ready():
	img.modulate = default_color

func loadSave(data: Dictionary):
	if data.is_empty():
		label.text = "Empty slot"
		img.texture = empty_tex
		return
	
	label.text = data.date
	var img_data = Marshalls.base64_to_raw(data.preview)
	var i: Image = Image.new()
	i.load_png_from_buffer(img_data)
	img.texture = ImageTexture.create_from_image(i)

func _on_texture_rect_mouse_entered():
	img.modulate = over_color

func _on_texture_rect_mouse_exited():
	img.modulate = default_color


func _on_texture_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			img.modulate = pressed_color
			clicked.emit()
		else:
			img.modulate = default_color
