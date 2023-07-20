@tool
extends Node
static var state: Dictionary = {}

func gs(id: String, default = null):
	var result = state[id] if state.has(id) else default
	return result
