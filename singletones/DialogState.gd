extends Node

signal updated(oldD: Dictionary, newD: Dictionary)

var dialog_state: Dictionary = {}

func setState(newD: Dictionary):
	var dict = {}
	for k in newD:
		dict[pps(k)] = pps(newD[k])
	var old = dialog_state.duplicate()
	for k in dict:
		dialog_state[k] = dict[k]
	updated.emit(old, dialog_state.duplicate())

func s(key, value):
	var dict = {}
	dict[key] = value
	setState(dict)

func gs(key):
	return str(dialog_state[key]) if dialog_state.has(key) else ""

func g(key):
	return dialog_state[key] if dialog_state.has(key) else null

func all():
	return dialog_state

func pps(s):
	if s is String:
		var result = s
		for k in dialog_state:
			result = result.replace("$(" + str(k) + ")", str(dialog_state[k]))
		return result
	return s
