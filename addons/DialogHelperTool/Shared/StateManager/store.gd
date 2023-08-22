extends Node
class_name StateManagerStore

var _state : Dictionary = {}
var _json = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()
var persistFunction : Callable
var serializer: Callable

signal updated(oldState, newState)

func setState(data: Dictionary):
	var oldData = _state.duplicate()
	for k in data.keys():
		if data[k] == null:
			_state.erase(k)
		else:
			_state.k = data[k]
	updated.emit(oldData, _state)
	if persistFunction:
		var str_data
		if serializer:
			str_data = serializer.call(str_data)
		else: 
			str_data = _json.serialize(_state)
		persistFunction.call(str_data)
