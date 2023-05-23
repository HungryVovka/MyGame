extends Control

@onready var first = $First
@onready var second = $Second
@onready var under = $Under
@onready var face = $Face

@export var movable = 40

var tween
var is_first = true

var shader_animations = []

func _ready():
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

func animateBackground(from, to, time): 
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(from, "modulate", Color.TRANSPARENT, time)
	tween.tween_property(to, "modulate", Color.WHITE, time)

func clear():
	first.texture = null
	second.texture = null

func set_texture(res, fade_time):
	if fade_time == 0.0:
		if is_first:
			first.texture = res
			first.modulate = Color.WHITE
		else:
			second.texture = res
			second.modulate = Color.WHITE
	else:
		if is_first:
			second.texture = res
			animateBackground(first, second, fade_time)
			is_first = false
		else:
			first.texture = res
			animateBackground(second, first, fade_time)
			is_first = true
		
func _input(event):
	scale = Vector2(1.0 + 0.1*movable/40, 1.0 + 0.1*movable/40)
	if event is InputEventMouseMotion:
		var x = min(max((event.position.x*1.0 - 1920/2.0)/960.0, -1.0), 1.0)
		var y = min(max((event.position.y*1.0 - 1080/2.0)/540.0, -1.0), 1.0)
		position = Vector2(-movable - x*movable, -movable - y*movable)
