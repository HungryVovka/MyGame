@tool
extends Control

@export var inactive_color: Color = Color(0.4,0.4,0.4, 1.0)
@export var items: Array[String] = [] : set = setItems
@export var enabled: bool = true: set = setEnabled
@export var text: String = "": set = setText, get = getText

@onready var optionButton = $OptionButton
@onready var line = $LineEdit
@onready var tex = $TextureRect
var is_ready: bool = false

var suggest_data: Array[String] = []
var suggest_ix: int = 0
var block_suggest: bool = false
var typed_len: int = 0

var state: Dictionary = {
	"stylebox" = null,
	"text" = ""
}

var active_shader: ShaderMaterial
var inactive_shader: ShaderMaterial


signal item_selected(text)

func _ready():
	is_ready = true
	
	active_shader = ShaderMaterial.new()
	active_shader.shader = preload("res://addons/DialogHelperTool/Shared/Dropdownbox/Dropdownbox.gdshader")
	
	inactive_shader = ShaderMaterial.new()
	inactive_shader.shader = preload("res://addons/DialogHelperTool/Shared/Dropdownbox/Dropdownbox.gdshader")
	inactive_shader.set_shader_parameter("is_active", false)
	
func setText(v: String):
	_on_line_edit_text_changed(v, true)
func getText() -> String:
	return line.text
	
func setScale(coef: float):
	var v = int($LineEdit.get_theme_font_size("font_size") * coef)
	add_theme_font_size_override("font_size", v)
	custom_minimum_size = Vector2(custom_minimum_size.x, 25 * coef)
	
func setEnabled(enabled: bool):
	if enabled:
		if state.stylebox:
			optionButton.add_theme_stylebox_override("normal", state.stylebox)
		optionButton.mouse_filter = MOUSE_FILTER_STOP
		line.mouse_filter = MOUSE_FILTER_STOP
		if line.text != "":
			item_selected.emit(line.text)
		tex.material = active_shader
	else:
		state.stylebox = optionButton.get_theme_stylebox("normal").duplicate()
		var stylebox: StyleBoxFlat = optionButton.get_theme_stylebox("normal").duplicate()
		stylebox.shadow_color = inactive_color
		stylebox.shadow_size = 1
		optionButton.add_theme_stylebox_override("normal", stylebox)
		optionButton.mouse_filter = MOUSE_FILTER_IGNORE
		line.mouse_filter = MOUSE_FILTER_IGNORE
		tex.material = inactive_shader

func setItems(data: Array[String]):
	if !is_ready:
		await self.ready
	optionButton.clear()
	items = data.duplicate()
	for i in range(0, data.size()):
		optionButton.add_item(data[i], i)


func _on_option_button_item_selected(index):
	line.text = items[index]
	item_selected.emit(items[index])


func _on_line_edit_text_changed(new_text: String, override_block_suggest = false):
	suggest_data = suggest(new_text)
	suggest_ix = 0
	if override_block_suggest:
		line.text = new_text
		
	if suggest_data.size() > 0 && !block_suggest && !override_block_suggest:
		_select_suggest()
	item_selected.emit(line.text)
	_update_option_item(line.text)

func _select_suggest():
	line.text = suggest_data[suggest_ix]
	line.select(typed_len, suggest_data[suggest_ix].length())
	line.caret_column = typed_len
	_update_option_item(line.text)
	
func _update_option_item(text):
	if items.has(text):
		optionButton.select(items.find(text))

func suggest(value: String, data: Array[String] = items) -> Array[String]:
	if value.length() < 2:
		return []
	var v = value.to_lower()
	var lowered: Array[String] = fixTypes(data.map(func (it: String): return it.to_lower()))
	var indexes: Array[int] = []
	for i in range(0, lowered.size()):
		if lowered[i].begins_with(v):
			indexes.push_back(i)
	var result: Array[String] = []
	for ix in indexes:
		result.push_back(data[ix])
	return result

func fixTypes(data: Array = []) -> Array[String]:
	var result: Array[String] = []
	result.assign(data)
	return result


func _on_line_edit_gui_input(event):
	if event is InputEventKey && event.pressed:
		block_suggest = event.keycode == KEY_BACKSPACE
		if (event.keycode == KEY_DOWN || event.keycode == KEY_UP) && suggest_data.size() > 0:
			suggest_ix = (suggest_ix + (1 if event.keycode == KEY_DOWN else -1)) % suggest_data.size()
			_select_suggest()
			item_selected.emit(line.text)
		if event.as_text().length() == 1: #check if symbol is text
			typed_len = line.text.length() + 1
