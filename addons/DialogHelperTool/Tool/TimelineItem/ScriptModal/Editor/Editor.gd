@tool
extends Control

@export var text: String = "": set = setText, get = getText
@export var src: Dictionary = {}: set = setSource
@onready var code = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/CodeEdit
@onready var statsContainer = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/StatsContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var statItem = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/StatsContainer/VBoxContainer/ScrollContainer/VBoxContainer/StatsItem

signal textSaved(text)
signal success(data)

var stats_children = []
var selected_item = null

func _on_code_edit_text_changed():
	pass
	
func setSource(data):
	src = data
	for c in stats_children:
		statsContainer.remove_child(c)
		c.queue_free()
	stats_children.clear()
	
	if src.has("state"):
		for k in src.state.keys():
			createItem(k, src.state[k])
			
func createItem(variable, value):
	var new_item = statItem.duplicate()
	new_item.visible = true
	new_item.variable = variable
	new_item.value = value
	statsContainer.add_child(new_item)
	stats_children.push_back(new_item)

func setText(s: String):
	code.text = s
	
func getText():
	return code.text

func _on_button_pressed():
	textSaved.emit(text)
	success.emit({"script": text})
	saveStats()

func _on_add_stat_button_pressed():
	createItem("", "")

func _on_stats_item_selected(node):
	selected_item = node

func _on_remove_stat_button_pressed():
	if selected_item:
		if stats_children.has(selected_item):
			stats_children.remove_at(stats_children.find(selected_item))
		statsContainer.remove_child(selected_item)
		selected_item.queue_free()
		selected_item = null

func saveStats():
	if stats_children.size() == 0 && src.has("state"):
		src.erase("state")
	else:
		var dict: Dictionary = src.state if src.has("state") else {}
		for i in stats_children:
			dict[i.variable] = i.value
		src.state = dict
