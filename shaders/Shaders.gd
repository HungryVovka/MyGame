extends Node

@export var list: Dictionary = {
	"god_light": "res://shaders/GodLight.gdshader",
	"vignette": "res://shaders/vingette.gdshader",
	"clouds": "res://shaders/сlouds.gdshader",
	"crt": "res://shaders/crt.gdshader"
}

func new_material(id: String, params: Dictionary = {}):
	if list.has(id):
		var mat = ShaderMaterial.new()
		mat.shader = load(list[id])
		for k in params.keys():
			mat.set_shader_parameter(k, params[k])
		return mat
	return null
