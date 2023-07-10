@tool
extends Control

@export var source: Dictionary = {"roots": {
	"/saying yes": {"id": 1},
	"/confirm": {"id": 2}
}}: set = setSource
var roots_children = []
@onready var root_item = $MarginContainer/Panel/VBoxContainer/ScrollContainer/VBoxContainer/RootItem
@onready var container = $MarginContainer/Panel/VBoxContainer/ScrollContainer/VBoxContainer
var selected_node

signal root_name_changed(old, new)

var _is_ready = false
func _ready():
	_is_ready = true
	setSource(source)

func setSource(data: Dictionary):
	if data.keys().size() == 0:
		return
	if !_is_ready:
		await self.ready
	source = data
	clearChildren()
	for r in source.roots.keys():
		create_item(r)
		
func create_item(k):
	var new_item = root_item.duplicate()
	new_item.editable = true
	new_item.visible = true
	new_item.ids = k
	new_item.text = k
	container.add_child(new_item)
	roots_children.push_back(new_item)
	
func clearChildren():
	for c in roots_children:
		if c && is_instance_valid(c):
			c.get_parent().remove_child(c)
			c.queue_free()
	roots_children.clear()
	
func generateName(txt: String):
	var ix = 0
	if source.roots.keys().has(txt):
		while true:
			ix += 1
			if !source.roots.keys().has(txt + str(ix)):
				return txt + str(ix)
	return txt

func _on_root_item_text_update(text, id, sender):
	if text == id:
		return
	if source.roots.keys().has(text) || text == "":
		var caret = sender.caret_column
		sender.text = id
		sender.caret_column = caret + 1
	else:
		root_name_changed.emit(id, text)
		source.roots[text] = source.roots[id]
		sender.ids = text
		source.roots.erase(id)

func _on_add_root_button_pressed():
	var r = generateName("/new_root")
	source.roots[r] = {"events": []}
	create_item(r)

func _on_remove_root_button_pressed():
	if selected_node: 
		source.roots.erase(selected_node.ids)
		selected_node.get_parent().remove_child(selected_node)
		selected_node.queue_free()
		selected_node = null

func _on_root_item_selected(node):
	selected_node = node
