@tool
extends EditorPlugin

var dock

var is_scanning

var bus_list: Array[String] = []

var dialogToolState = preload("res://addons/DialogHelperTool/Shared/DialogToolState.gd").new()

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if dock:
		dock.visible = visible
	get_editor_interface().get_editor_settings().set_setting("run/auto_save/save_before_running", !visible)

func _exit_tree():
	get_editor_interface().get_editor_main_screen().remove_child(dock)
	dock.queue_free()
	remove_custom_type("ChoiceControlContainer")
	remove_custom_type("DialogLayout")
	

func _enter_tree():
	dialogToolState.state.scale = get_editor_interface().get_editor_scale()
	dock = preload("res://addons/DialogHelperTool/Tool/DialogHelperTool.tscn").instantiate()
	dock.interface_scale = get_editor_interface().get_editor_scale()
	get_editor_interface().get_editor_main_screen().add_child(dock)
	dock.connect("reimport", rescan_fs)
	
	add_custom_type("ChoiceControlContainer", "Control", load("res://addons/DialogHelperTool/Game/ChoiceControl/ChoiceSceneContainer.gd"), null)
	add_custom_type("DialogLayout", "Control", load("res://addons/DialogHelperTool/Game/DialogScene/DialogLayout.gd"), null)
	var bus_resource = load("res://default_bus_layout.tres")
	for i in range(0, 999):
		var iBus = bus_resource.get("bus/" + str(i) + "/name")
		if iBus:
			bus_list.push_back(iBus)
		else:
			break
	dock.bus_list = bus_list	
	_make_visible(false)

func _get_plugin_name():
	return "Dialog Helper Tool"
	
func rescan_fs(filename):
	get_editor_interface().get_resource_filesystem().scan()
	get_editor_interface().get_resource_filesystem().scan_sources()
