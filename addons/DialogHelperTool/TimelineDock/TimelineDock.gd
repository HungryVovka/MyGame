@tool
extends Control

@export var interface_scale: float = 1.0

var data: Dictionary

func _ready():
	pass

func activate(src: Dictionary):
	var parent: TabContainer = get_parent()
	var tabs = []
	for i in range(0, parent.get_tab_count()):
		tabs.push_back(parent.get_tab_title(i))
	if tabs.has(name):
		parent.current_tab = tabs.find(name)
	data = src
	represent()
	
func represent():
	pass
		
