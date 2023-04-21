extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var dialog = Dialogic.start("res://timelines/start.dtl")
	add_child(dialog)
	pass
