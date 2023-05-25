extends Control

@onready var first = $First
@onready var under = $Under
@onready var face = $Face
@onready var back = $Back

@export var movable = 40

var tween
var is_first = true

var shader_animations = []

var shader = preload("res://shaders/AnimatedShader.gd").new()

func _ready():
	shader.set_material(first.material, "time")
	shader.reset_time()
	add_child(shader)
	pass

func apply_shader(id: String, params: Dictionary, texture = null, where: String = "under"):
	var mat = Shaders.new_material(id, params)
	var dest: TextureRect = under if where == "under" else face
	if id != "":
		dest.texture = load(texture) if texture else load("res://Resources/1Main/GUI/Menus/game_menu.png")
	else:
		dest.texture = null
	dest.material = mat if mat else null
	
	if (id != ""): 
		var a_class = preload("res://shaders/AnimatedShader.gd")
		var a = a_class.new()
		a.set_material(dest.material, "time")
		shader_animations.push_back(a)
		add_child(a)
		
func remove_shader(where: String = "under"):
	var dest: TextureRect = under if where == "under" else face
	dest.material = null
	dest.texture = null

func clear():
	first.texture = null
	
func set_background(res, has_transition: bool = false, shader_params: Dictionary = {}):
	if has_transition:
		swap_textures()
		if first.texture == null || !(shader_params.has("blend") && shader_params.blend):
			first.texture = res
		first.material.set_shader_parameter("secondTexture", res)
	else:
		first.texture = res
	shader.reset_time()
	if has_transition:
		for k in shader_params:
			if k == "blend":
				continue;
			if k == "fade_color":
				first.material.set_shader_parameter(k, Color.html(shader_params[k]))
			else:
				first.material.set_shader_parameter(k, shader_params[k])
	else:
		reset_transition()

		
func reset_transition():
	first.material.set_shader_parameter("swipe_mode_h", null)
	first.material.set_shader_parameter("swipe_mode_v", null)
	first.material.set_shader_parameter("swipe_speed_h", null)
	first.material.set_shader_parameter("swipe_speed_v", null)
	first.material.set_shader_parameter("swipe_min_h", null)
	first.material.set_shader_parameter("swipe_max_h", null)
	first.material.set_shader_parameter("swipe_min_v", null)
	first.material.set_shader_parameter("swipe_max_v", null)
	first.material.set_shader_parameter("swipe_shift_h", null)
	first.material.set_shader_parameter("swipe_shift_v", null)
	
	first.material.set_shader_parameter("scale_mode", null)
	first.material.set_shader_parameter("scale_speed", null)
	first.material.set_shader_parameter("scale_min", null)
	first.material.set_shader_parameter("scale_max", null)
	first.material.set_shader_parameter("scale_shift", null)
	
	first.material.set_shader_parameter("shade_mode", null)
	first.material.set_shader_parameter("shake_v", null)
	first.material.set_shader_parameter("shake_h", null)
	first.material.set_shader_parameter("shake_speed", null)
	first.material.set_shader_parameter("shake_height", null)
	first.material.set_shader_parameter("shake_time", null)
	
	first.material.set_shader_parameter("blend_mode", null)
	first.material.set_shader_parameter("blend_speed", null)
	
	first.material.set_shader_parameter("fade_color", null)
	first.material.set_shader_parameter("fade_to", null)
	first.material.set_shader_parameter("fade_from", null)
	first.material.set_shader_parameter("fade_speed", null)
	
	first.material.set_shader_parameter("slide_h", null)
	first.material.set_shader_parameter("slide_v", null)
	first.material.set_shader_parameter("slide_speed", null)
	first.material.set_shader_parameter("slide_reverse", null)

func swap_textures():
	var tex = first.texture
	first.texture = first.material.get_shader_parameter("secondTexture")
	back.texture = first.texture
	first.material.set_shader_parameter("secondTexture", tex)
		
func _input(event):
	scale = Vector2(1.0 + 0.1*movable/40, 1.0 + 0.1*movable/40)
	if event is InputEventMouseMotion:
		var x = min(max((event.position.x*1.0 - 1920/2.0)/960.0, -1.0), 1.0)
		var y = min(max((event.position.y*1.0 - 1080/2.0)/540.0, -1.0), 1.0)
		position = Vector2(-movable - x*movable, -movable - y*movable)
