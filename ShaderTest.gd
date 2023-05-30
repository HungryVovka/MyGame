extends Control
# Called when the node enters the scene tree for the first time.
@onready var rect =$TextureRect

func _ready():
	var animator = preload("res://shaders/AnimatedShader.gd")
	var shader = animator.new()
	shader.set_material(rect.material, "time")
	add_child(shader)
func _process(delta):
	pass