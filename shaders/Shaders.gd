extends Node

@export var list: Dictionary = {
	"god_light": "res://shaders/GodLight.gdshader"
}

func new_material(id: String, params: Dictionary = {}):
	if list.has(id):
		var mat = ShaderMaterial.new()
		mat.shader = load(list[id])
		for k in params.keys():
			mat.set_shader_parameter(k, params[k])
		return mat
	return null
