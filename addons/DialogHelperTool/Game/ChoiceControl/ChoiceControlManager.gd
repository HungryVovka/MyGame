extends Node

signal make_choice(id)

var items = []

func _ready():
	items = findChoiceControls(get_all_children(get_parent()))
	for i in items:
		i.connect("pressed", on_make_choice)
	
func get_all_children(in_node, arr = []):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func findChoiceControls(items: Array): 
	var foundChoices = []
	for i in items:
		var item: Node = i
		var props = item.get_property_list()
		for p in props:
			if p["name"] == "choice_type":
				foundChoices.push_back(i)
	return foundChoices
	
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
