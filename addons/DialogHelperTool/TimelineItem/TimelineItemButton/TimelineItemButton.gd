@tool
extends Control

@export var text: String = "T": set = setText
@export var tooltip: String = "": set = setTooltip
@export var icon: Texture2D: set = setIcon

@onready var button = $Button
@onready var iconObj = $MarginContainer/Icon

var shader_active: ShaderMaterial
var shader_inactive: ShaderMaterial

signal toggled(pressed)

var _is_ready = false
func _ready():
	_is_ready = true
	
	shader_active =  iconObj.material.duplicate()
	shader_inactive =  iconObj.material.duplicate()
	shader_inactive.set_shader_parameter("is_active", false)
	
func _on_ready():
	if !_is_ready:
		await self.ready

func setText(s: String):
	await _on_ready()
	button.text = s
	text = s
	
func setTooltip(s: String):
	await _on_ready()
	button.tooltip_text = s
	tooltip = s
	
func setIcon(s: Texture2D):
	await _on_ready()
	icon = s
	iconObj.texture = s	

func setScale(scale: float):
	self.custom_minimum_size = self.custom_minimum_size*scale
	
func setActive(is_active: bool):
		iconObj.material = shader_active if is_active else shader_inactive

func _on_button_toggled(button_pressed):
	toggled.emit(button_pressed)
