@tool
extends Control

var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()
var dialogToolState = preload("res://addons/DialogHelperTool/Shared/DialogToolState.gd").new()
var _default_src = {
	"choices": {
		"id": "choice_block",
		"choices": [{
			"id": "choice_id",
			"text": "Choice id",
			"root": "./choice_block/choice_id",
			"script": ""
		}],
		"scene": ""
	}
}

var _empty_choices = {
	"id": "my_choice",
	"choices": []
}

@export var src: Dictionary = JSONHelper.deep_duplicate(_default_src): set = setSource
var root_prefix: String = "/."
@export var roots: Array = []

@onready var block = $Panel/MarginContainer/MarginContainer
@onready var enabled_checkbox = $Panel/MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer/EnabledCheckbox
@onready var enabled_block = $Panel/MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer

@onready var choice_block_id = $Panel/MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer/ChoiceId
@onready var choice_scene = $Panel/MarginContainer/VBoxContainer/SceneContainer/HBoxContainer/ChoiceScene
@onready var choice_scene_checkbox = $Panel/MarginContainer/VBoxContainer/SceneContainer/HBoxContainer/CheckBox

@onready var add_choice_button = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AddChoice
@onready var remove_choice_button = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/RemoveChoice

@onready var choice_container = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var choice_item = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/ChoiceItem

@onready var config_box = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/ConfigBox
@onready var choice_id = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/ConfigBox/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ChoiceId
@onready var condition_checkbox = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/ConfigBox/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/ConditionCheckbox
@onready var condition_editor = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/ConfigBox/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Condition

@onready var root_list = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/ConfigBox/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer/Dropdownbox
@onready var go_to_root_button = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/ConfigBox/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer/GoToRoot
@onready var create_root_button = $Panel/MarginContainer/VBoxContainer/ListContainer/HBoxContainer/VBoxContainer/ConfigBox/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer/CreateRoot

var children_items = []
var prev_item
var selected_element = {}
var selected_sender: Node
var render_started: bool = false

var old_text: String = ""

signal create_root(name)
signal open_root(name)

func setSource(data: Dictionary):
	if !is_node_ready():
		return
	src = data
	prev_item = null
	render()
	
func clean():
	prev_item = null
	
func _ready():
	block.add_theme_constant_override("margin_top", enabled_block.size.y + 16)
	add_child(JSONHelper)
	root_list.setScale(dialogToolState.gs("scale", 1.0))

func render(create_empty: bool = false):
	clear_ui()
	
	render_started = true
	if !src.has("choices"):
		if prev_item:
			src["choices"] = prev_item
		else:
			if create_empty:
				src["choices"] = JSONHelper.deep_duplicate(_empty_choices)
			else:
				render_started = false
				enabled_checkbox.button_pressed = false
				return
	if enabled_checkbox.button_pressed != src.has("choices"):
		enabled_checkbox.button_pressed = src.has("choices")
	
	choice_block_id.text = src.choices.id
	if src.choices.has("scene"):
		choice_scene_checkbox.button_pressed = true
		choice_scene.text = src.choices.scene
	for c in src.choices.choices:
		var new_choice = choice_item.duplicate()
		new_choice.visible = true
		new_choice.text = c.text
		new_choice.src = c
		children_items.push_back(new_choice)
		choice_container.add_child(new_choice)
	root_list.items = roots
	render_started = false
		
func clear_ui():
	for c in children_items:
		choice_container.remove_child(c)
		c.queue_free()
	selected_element = null
	children_items.clear()
	enabled_checkbox.button_pressed = false
	choice_block_id.text = ""
	choice_id.text = ""
	choice_scene_checkbox.button_pressed = false
	choice_scene.text = ""
	condition_checkbox.button_pressed = false
	condition_editor.text = "func condition(_dialog, _event):\nreturn true"
	root_list.items = root_list.fixTypes([])
	root_list.text = ""
	config_box.visible = false

func _on_enabled_checkbox_toggled(button_pressed):
	if render_started:
		block.visible = !button_pressed
		return
	if !is_node_ready():
		await ready
	block.visible = !button_pressed
	
	if !button_pressed:
		if src.has("choices"):
			prev_item = src.choices
			src.erase("choices")
		clear_ui()
	else:
		render(true)

func _on_choice_item_on_focused(sender, data):
	selected_element = data
	selected_sender = sender
	old_text = data.text
	render_item_config()

func render_item_config():
	config_box.visible = true
	old_text = selected_element.id
	choice_id.text = selected_element.id
	condition_checkbox.button_pressed = selected_element.has("script")
	condition_editor.text = selected_element.script if selected_element.has("script") else ""
	root_list.text = selected_element.root
	root_list.enabled = true
	
	
func generate_id(data: Dictionary):
	var tokens: Array = str(data.text).split(" ")
	tokens = tokens.slice(0,min(3, tokens.size()))
	return str(tokens.reduce(func (accum, v): return accum + "_" + v, "")).substr(1).to_lower()
	
func generate_root(data: Dictionary):
	return root_prefix + "/" + choice_block_id.text + "/" + (data.id if data.has("id") else generate_id(data))

func _on_add_choice_pressed():
	var new_choice = choice_item.duplicate()
	new_choice.visible = true
	var cfg = {
		"id": "choice_id",
		"text": "Choice id",
		"root": ""
	}
	cfg.root = generate_root(cfg)
	new_choice.text = cfg.text
	src.choices.choices.push_back(cfg)
	new_choice.src = cfg
	children_items.push_back(new_choice)
	choice_container.add_child(new_choice)


func _on_choice_id_text_changed(new_text):
	if src.has("choices") && selected_element:
		selected_element.id = new_text
		if should_generate_root(old_text):
			var rt = generate_root(selected_element)
			selected_element.root = generate_root(selected_element)
			root_list.text = selected_element.root
		old_text = new_text
	

func _on_choice_item_text_changed():
	if selected_element:
		selected_element.text = selected_sender.text
		if should_generate_id():
			selected_element.id = generate_id(selected_element)
			choice_id.text = selected_element.id
			if should_generate_root(old_text):
				selected_element.root = generate_root(selected_element)
				root_list.text = selected_element.root
		old_text = selected_element.text
	
	
func should_generate_id():
	return generate_id({"text": old_text}) == selected_element.id if selected_element else false
	
func should_generate_root(text: String):
	return generate_root({"text": text}) == selected_element.root if selected_element else false

func _on_remove_choice_pressed():
	if src.has("choices") && src.choices.choices.size() > 0:
		for ix in range(children_items.size()):
			var item = children_items[ix]
			if item == selected_sender:
				src.choices.choices.remove_at(ix)
				choice_container.remove_child(item)
				item.queue_free()
				children_items.remove_at(ix)
				selected_element = {}
				selected_sender = null
				config_box.visible = false
				break
	

func _on_choice_scene_text_changed(new_text):
	print("c", new_text)
	if src.has("choices") && new_text != "":
		src.choices.scene = new_text
	else:
		src.choices.erase("scene")
	

func _on_check_box_pressed():
	if !enabled_checkbox.button_pressed:
		return
	var en = choice_scene_checkbox.button_pressed
	if en:
		src.choices.scene = choice_scene.text
	else:
		src.choices.erase("scene")
	

func _on_condition_checkbox_pressed():
	if selected_element:
		var en = condition_checkbox.button_pressed
		if en:
			selected_element.script = condition_editor.text
		else:
			selected_element.erase("script")

func _on_condition_text_changed():
	if selected_element:
		var en = condition_checkbox.button_pressed
		if en:
			selected_element.script = condition_editor.text

func _on_create_root_pressed():
	create_root.emit(root_list.text)
	roots.push_back(root_list.text)
	root_list.items = roots
	updateButtons()

func _on_go_to_root_pressed():
	open_root.emit(root_list.text)

func _on_dropdownbox_item_selected(text):
	if render_started:
		return
	if selected_element:
		selected_element.root = text
	updateButtons()

func updateButtons():
	var root: String = root_list.text
	var is_root = root.begins_with("/")
	if is_root:
		create_root_button.disabled = roots.has(root)
		go_to_root_button.disabled = !roots.has(root)
	else:
		create_root_button.disabled = true
		go_to_root_button.disabled = true
