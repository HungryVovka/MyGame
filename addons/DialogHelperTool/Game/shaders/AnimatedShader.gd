extends Node

@export var mat: ShaderMaterial
@export var time: float = 0.0
var property: String = ""
var paused: bool = false

func set_material(m: ShaderMaterial, prop: String):
	mat = m
	property = prop

func reset_time():
	time = 0

func _process(delta):
	if !paused:
		time += delta
		if mat:
			mat.set_shader_parameter(property, time)
