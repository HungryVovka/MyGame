@tool
extends EditorPlugin

var dock

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if dock:
		dock.visible = visible
func _exit_tree():
	pass

func _enter_tree():
	dock = preload("res://addons/DialogHelperTool/DialogHelperTool.tscn").instantiate()
	dock.scale = Vector2(0.1, 0.1)
	get_editor_interface().get_editor_main_screen().add_child(dock)
	_make_visible(false)

func _get_plugin_name():
	return "Dialog Helper Tool"
