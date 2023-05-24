extends Control

@onready var rect = $TextureRect
@onready var animator = preload("res://shaders/AnimatedShader.gd")
var shader

func _ready():
	shader = animator.new()
	shader.set_material(rect.material, "time")
	add_child(shader)
	
func swap_textures():
	var tex = rect.texture
	rect.texture = rect.material.get_shader_parameter("secondTexture")
	rect.material.set_shader_parameter("secondTexture", tex)

func _on_texture_rect_gui_input(event):
	var movable = 40.0
	scale = Vector2(1.0 + 0.1*movable/40, 1.0 + 0.1*movable/40)
	if event is InputEventMouseMotion:
		var x = min(max((event.position.x*1.0 - 1920/2.0)/960.0, -1.0), 1.0)
		var y = min(max((event.position.y*1.0 - 1080/2.0)/540.0, -1.0), 1.0)
		rect.position = Vector2(-movable - x*movable, -movable - y*movable)
