@tool
extends LineEdit

@export var ids: String = ""

signal text_update(text, id, sender)
signal selected(node)

func _on_root_item_text_changed(new_text: String):
	if !new_text.begins_with("/"):
		var p = caret_column
		text = "/" + new_text
		caret_column = p + 1
	text_update.emit(text, ids, self)


func _on_focus_entered():
	selected.emit(self)
