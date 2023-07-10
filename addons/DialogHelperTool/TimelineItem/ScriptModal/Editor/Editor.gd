@tool
extends Control

@export var text: String = "": set = setText, get = getText
@onready var code = $Panel/MarginContainer/VBoxContainer/CodeEdit

signal textSaved(text)
signal success(data)

func _on_code_edit_text_changed():
	pass

func setText(s: String):
	code.text = s
	
func getText():
	return code.text

func _on_button_pressed():
	textSaved.emit(text)
	success.emit({"script": text})
