extends Control

@export_multiline var text:  set =  setText, get = getText

@export var charactersPerSecond: int = 50

@export var nextOnClick: bool = true

@onready var richLabel = $RichLabel

signal on_text_clicked(event)
signal on_next()

var _text = ""

func setText(value):
	if richLabel:
		_update_rich_label(value, value.length() / charactersPerSecond)
	else:
		if value != null:
			_text = value
		
func getText():
	if richLabel:
		return richLabel.text
	else: 
		return ""

func _ready():
	if _text:
		_update_rich_label(_text, _text.length() / charactersPerSecond)
		_text = ""

func _update_rich_label(value, time):
	richLabel.set_text_animation(value, time)
	
func next():
	if richLabel.visible_ratio < 1.0:
		richLabel.visible_ratio = 1.0
	else:
		on_next.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_rich_label_gui_input(event):
	if event is InputEventMouseButton:
		on_text_clicked.emit(event)
		if nextOnClick && event.button_index == MOUSE_BUTTON_LEFT && event.pressed == true:
			next()
	pass # Replace with function body.
