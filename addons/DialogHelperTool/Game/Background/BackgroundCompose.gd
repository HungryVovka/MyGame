@tool
extends Control

@export var movable = 40: set = setMovable
@export var skip_blend_time: float = 999.0

@onready var first = $First
@onready var second = $Second
@onready var current = second: set = setCurrent

@onready var under = $Under
@onready var face = $Face

var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()
var shader_animations = {}
var prev_had_blend = false

func switch(forward: bool):
	if forward:
		move_child(first, 2)
	else:
		move_child(first, 1)
		
func setCurrent(node: Node):
	switch(node == first)
	current = node

func swapCurrent():
	current = second if current == first else first
	
func other():
	return first if current == second else second

func setMovable(value):
	first.movable = value
	second.movable = value
	
	
func set_background(res, has_transition: bool = false, shader_params: Dictionary = {}):
	if !has_transition:
		current = second
		current.set_background(res, has_transition, shader_params)
	else:
		if shader_params.has("blend"):
			if prev_had_blend:
				current.shader.time += skip_blend_time #ending previous blend
			swapCurrent()
			prev_had_blend = true
		else:
			prev_had_blend = false
			
		if JSONHelper.gb(shader_params, ["curtain_h", "curtain_v", "slide_h", "slide_v"]):
			if shader_params.has("blend"):
				current.set_background(other().get_texture(), has_transition, shader_params, res)
			else:
				current.set_background(current.get_texture(), has_transition, shader_params, res)
		else:
			current.set_background(res, has_transition, shader_params)

func apply_shader(id: String, params: Dictionary, texture = null, where: String = "under"):
	var mat = Shaders.new_material(id, params)
	var dest: TextureRect = under if where == "under" else face
	if id != "":
		dest.texture = load(texture) if texture else NoiseTexture2D.new()
	else:
		dest.texture = null
	dest.material = mat if mat else null
	
	if (id != ""): 
		var a_class = preload("res://addons/DialogHelperTool/Game/shaders/AnimatedShader.gd")
		var a = a_class.new()
		a.set_material(dest.material, "time")
		shader_animations[where] = a
		add_child(a)
		
func remove_shader(where: String = "under"):
	var dest: TextureRect = under if where == "under" else face
	shader_animations.erase(where)
	dest.material = null
	dest.texture = null
	
func reset_shaders():
	if !is_node_ready():
		await ready
	first.reset_shaders()
	second.reset_shaders()
	
func _on_button_pressed():
	swapCurrent()
