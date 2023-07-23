@tool
extends TextEdit

var src: Dictionary = {}

signal on_focused(sender, data)


func _on_focus_entered():
	on_focused.emit(self, src)
