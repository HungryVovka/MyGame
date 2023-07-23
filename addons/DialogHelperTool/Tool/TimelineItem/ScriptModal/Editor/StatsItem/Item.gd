@tool
extends MarginContainer

var variable = "": set = setVariable
var value = "": set = setValue

signal selected(node)

func _on_line_edit_text_changed(new_text):
	variable = new_text

func _on_var_value_text_changed(new_text):
	value = new_text

func setVariable(s):
	var node = $PanelContainer/HBoxContainer/PanelContainer/VarName
	var pos = node.caret_column
	node.text = s
	variable = s
	node.caret_column = pos
	
func setValue(s):
	var node = $PanelContainer/HBoxContainer/PanelContainer2/VarValue
	var pos = node.caret_column
	node.text = s
	value = s
	node.caret_column = pos

func _on_var_name_focus_entered():
	selected.emit(self)
