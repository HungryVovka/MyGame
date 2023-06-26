@tool
extends Popup

signal textSaved(text)
@export var sender: Node
@export var text: String: set = setText

@onready var editor = $Editor
var _is_ready : bool = false
		
func setText(text):
	if !_is_ready:
		await self.ready
	editor.text = text

func _ready():
	_is_ready = true

func _on_editor_text_saved(text):
	textSaved.emit(text)
	hide()
