@tool
extends EditorPlugin

var dock
var side_dock

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if dock:
		dock.visible = visible
	if (visible):
		dock.restore_scale()
func _exit_tree():
	remove_control_from_docks(side_dock)

func _enter_tree():
	dock = preload("res://addons/DialogHelperTool/DialogHelperTool.tscn").instantiate()
	dock.interface_scale = get_editor_interface().get_editor_scale()
	get_editor_interface().get_editor_main_screen().add_child(dock)
	
	side_dock = preload("res://addons/DialogHelperTool/TimelineDock/TimelineDock.tscn").instantiate()
	side_dock.interface_scale = get_editor_interface().get_editor_scale()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, side_dock)
	
	dock.connect("event_selected", _activate_side_dock)
	_make_visible(false)

func _get_plugin_name():
	return "Dialog Helper Tool"

func _activate_side_dock(data):
	side_dock.activate(data)
