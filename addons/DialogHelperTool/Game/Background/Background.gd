extends Control

@onready var first = $First
@onready var back = $Back

@export var movable = 40: set = setMovable
var is_first = true

var shader = preload("res://addons/DialogHelperTool/Game/shaders/AnimatedShader.gd").new()

func setMovable(value):
	movable = value
	if movable == 0:
		position = Vector2(0,0)
		scale = Vector2(1.0, 1.0)
	else: 
		scale = Vector2(1.0 + 0.1*movable/40, 1.0 + 0.1*movable/40)

func _ready():
	first.material = ShaderMaterial.new()
	first.material.shader = load("res://addons/DialogHelperTool/Game/shaders/transitions.gdshader")
	shader.set_material(first.material, "time")
	shader.reset_time()
	add_child(shader)
	
	if movable != 0:
		setMovable(movable)
	follow_cursor(get_viewport().get_mouse_position())
	

func reset_shaders():
	shader.reset_time()
	reset_transition()

func clear():
	first.texture = null
	
func get_texture():
	if !first.material.get_shader_parameter("secondTexture"):
		return first.texture
	else:
		return first.material.get_shader_parameter("secondTexture")
	
func set_background(res, has_transition: bool = false, shader_params: Dictionary = {}, secondTexture = null):
	shader.reset_time()
	back.visible = has_transition
	if secondTexture:
		first.texture = res
		first.material.set_shader_parameter("secondTexture", secondTexture)
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
		
func _input(event):
	if movable > 0 && scale == Vector2(1.0, 1.0):
		scale = Vector2(1.0 + 0.1*movable/40, 1.0 + 0.1*movable/40)
	if event is InputEventMouseMotion:
		follow_cursor(event.position)

func follow_cursor(pos: Vector2):
	var x = min(max((pos.x*1.0 - 1920/2.0)/960.0, -1.0), 1.0)
	var y = min(max((pos.y*1.0 - 1080/2.0)/540.0, -1.0), 1.0)
	position = Vector2(-movable - x*movable, -movable - y*movable)
