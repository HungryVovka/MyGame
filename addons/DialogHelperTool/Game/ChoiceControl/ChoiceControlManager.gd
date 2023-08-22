extends Node

signal make_choice(id)

var LayoutManager = preload("res://addons/DialogHelperTool/Shared/LayoutManager.gd").new()

var items = []

func _ready():
	items = LayoutManager.findControlsInChildren(get_parent(), "CHOICE_CONTROL")
	for i in items:
		i.connect("pressed", on_make_choice)
	
func on_make_choice(id: String):
	make_choice.emit(id)

func setEvent(event):
	if !is_node_ready():
		await ready
	for i in items:
		i.visible = false
	for c in event.choices:
		for i in items:
			if c.id == i.choice_id:
				i.visible = true
