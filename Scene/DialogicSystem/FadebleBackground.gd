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

func reset_shaders():
	shader.reset_time()
	reset_transition()

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
	
func dict_bool(dict: Dictionary, key: String):
	return dict.has(key) && dict[key]
func should_update_texture(shader_params: Dictionary):
	var key_list = ["blend", "curtain_h", "curtain_v"]
	for k in key_list:
		if dict_bool(shader_params, k):
			return false
	return true
		
	
func set_background(res, has_transition: bool = false, shader_params: Dictionary = {}):
	shader.reset_time()
	back.visible = has_transition
	if has_transition:
		swap_textures()
		if first.texture == null || should_update_texture(shader_params):
			first.texture = res
		first.material.set_shader_parameter("secondTexture", res)
	else:
		first.texture = res
		first.material.set_shader_parameter("secondTexture", null)
	if has_transition:
		reset_transition()
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
	var params_list: Array = first.material.get_shader().get_shader_uniform_list()
	params_list.remove_at(0);
	params_list.remove_at(params_list.size() - 1)
	for p in params_list:
		first.material.set_shader_parameter(p["name"], null)

func swap_textures():
	var tex = first.texture
	var sec = first.material.get_shader_parameter("secondTexture")
	if sec:
		first.texture = sec
		back.texture = first.texture
	first.material.set_shader_parameter("secondTexture", tex)
		
func _input(event):
	scale = Vector2(1.0 + 0.1*movable/40, 1.0 + 0.1*movable/40)
	if event is InputEventMouseMotion:
		var x = min(max((event.position.x*1.0 - 1920/2.0)/960.0, -1.0), 1.0)
		var y = min(max((event.position.y*1.0 - 1080/2.0)/540.0, -1.0), 1.0)
		position = Vector2(-movable - x*movable, -movable - y*movable)
