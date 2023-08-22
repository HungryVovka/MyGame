extends Node

func get_all_children(in_node, arr = []):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func findControlsInChildren(node: Node, type, first = false):
	var items : Array = get_all_children(node, [])
	var foundChoices = []
	for i in items:
		var item: Node = i
		var props = item.get_property_list()
		for p in props:
			if p["name"] == "dialog_tool_type" && item[p.name] == type:
				foundChoices.push_back(i)
	if first:
		return foundChoices[0] if foundChoices.size() > 0 else null
	return foundChoices
