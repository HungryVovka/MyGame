extends Node

@export var context: Dictionary = {}

var cond_example = {
	"op": "and",
	"data": [
		{
			"op": ">",
			"var": "$(value)",
			"value": "$(v3)",
			"cast": "float"
		},
		{
			"op": "==",
			"var": "v2",
			"value": "50",
			"cast": "int"
		}
	]
}

var context_example = {
	"test": "rawka",
	"v1": "10",
	"v2": "50",
	"v3": "-100",
	"v4": "2.5",
	"value": "v1"
}

func _ready():
	pass

func process(condition: Dictionary):
	match (condition.op):
		"==": return _key(condition) == _value(condition)
		"!=": return _key(condition) != _value(condition)
		">":  return _key(condition) > _value(condition)
		"<":  return _key(condition) < _value(condition)
		">=": return _key(condition) >= _value(condition)
		"<=": return _key(condition) <= _value(condition)
		"or": return _or(condition)
		"and": return _and(condition)
		"nor": return !_or(condition)
		"nand": return !_and(condition)
	return false
	
func _or(condition: Dictionary):
	var result = false
	for cond in condition["data"]:
		if (process(cond)):
			result = true
			break
	return result

func _and(condition: Dictionary):
	var result = true
	for cond in condition["data"]:
		if (!process(cond)):
			result = false
			break
	return result

func _key(condition: Dictionary):
	var _type = condition["cast"] if condition.has("cast") else ""
	return _cast(_pp(_getV(_pp(condition["var"]))), _type)

func _value(condition: Dictionary):
	var _type = condition["cast"] if condition.has("cast") else ""
	return _cast(_pp(condition["value"]), _type)

func _getV(v: String):
	if context.has(v):
		return context[v]
	else:
		return ""
	
func _pp(s: String):
	var result = s
	for k in context:
		result = result.replace("$(" + k + ")", context[k])
	return result

func _cast(value: String, type: String):
	if type == "int":
		return int(value)
	if (type == "float"):
		return float(value)
	return value
