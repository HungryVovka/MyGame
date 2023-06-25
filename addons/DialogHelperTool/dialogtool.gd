@tool
extends EditorPlugin

var dock
var side_dock

var is_scanning

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if dock:
		dock.visible = visible
	if (visible):
		dock.restore_scale()
func _exit_tree():
	remove_control_from_docks(side_dock)
	
func _process(_delta):
	var sc = get_editor_interface().get_resource_filesystem().is_scanning()
	if is_scanning != sc:
		print(get_editor_interface().get_resource_filesystem().is_scanning())
		is_scanning = sc

func _enter_tree():
	dock = preload("res://addons/DialogHelperTool/DialogHelperTool.tscn").instantiate()
	dock.interface_scale = get_editor_interface().get_editor_scale()
	get_editor_interface().get_editor_main_screen().add_child(dock)
	dock.connect("event_selected", _activate_side_dock)
	dock.connect("reimport", rescan_fs)
	
	_make_visible(false)

func _get_plugin_name():
	return "Dialog Helper Tool"
	
func rescan_fs(filename):
	print("rescan: ", filename)
	get_editor_interface().get_resource_filesystem().update_file(filename)
	get_editor_interface().get_resource_filesystem().reimport_files([filename])
	get_editor_interface().get_resource_filesystem().scan()
	get_editor_interface().get_resource_filesystem().scan_sources()

func _activate_side_dock(data):
	side_dock.activate(data)
