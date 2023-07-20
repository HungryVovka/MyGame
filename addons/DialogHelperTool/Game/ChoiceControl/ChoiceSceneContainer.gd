extends Control
signal make_choice(id)

var manager
@export var choices: Dictionary: set = setChoiceEvent

func _ready():
	manager = preload("res://addons/DialogHelperTool/Game/ChoiceControl/ChoiceControlManager.tscn").instantiate()
	add_child(manager)
	manager.connect("make_choice", _on_choice_control_manager_make_choice)
	
func _on_choice_control_manager_make_choice(id):
	make_choice.emit(id)
	
func setChoiceEvent(data):
	if !is_node_ready():
		await ready
	if data:
		manager.setEvent(data)
