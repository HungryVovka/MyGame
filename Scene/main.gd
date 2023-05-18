extends Control

@onready var label = $Label

func _ready():
	DialogState.connect("updated", update_label)
	DialogState.s("scores", 100)

func update_label(_oldV, _newV):
	label.text = "Scores: " + DialogState.gs("scores")
	
