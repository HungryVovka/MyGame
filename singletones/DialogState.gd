extends Node

signal updated(oldD: Dictionary, newD: Dictionary)

var dialog_state: Dictionary = {}
var scene_state: Dictionary = {}

func setState(newD: Dictionary):
	var dict = {}
	for k in newD:
		dict[pps(k)] = pps(newD[k])
	var old = dialog_state.duplicate()
	for k in dict:
		dialog_state[k] = dict[k]
	updated.emit(old, dialog_state.duplicate())

func getState():
	return dialog_state.duplicate()

func s(key, value):
	var dict = {}
	dict[pps(key)] = pps(value)
	setState(dict)
	
func r(key):
	if dialog_state.has(pps(key)):
		dialog_state.erase(pps(key))

func has(key):
	return dialog_state.has(pps(key))

func gs(k):
	return str(dialog_state[pps(k)]) if dialog_state.has(pps(k)) else ""

func g(k):
	return dialog_state[pps(k)] if dialog_state.has(pps(k)) else null

func all():
	return dialog_state

func pps(st):
	if st is String:
		var result = st
		for k in dialog_state:
			result = result.replace("$(" + str(k) + ")", str(dialog_state[k]))
		return result
	return st
	
func setSceneState(dict):
	scene_state = dict

