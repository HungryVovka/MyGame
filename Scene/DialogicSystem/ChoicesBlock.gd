extends Control
@onready var button = $VBoxContainer/Button
@onready var vbox = $VBoxContainer

var choices: Dictionary = {}
signal choiceClicked(id, text)


func _ready():
	button.visible = false
	pass
	
func set_choices(data: Array):
	clearChoices()
	addChoices(data)
	
func addChoices(data: Array):
	var ix = 0
	for choice in data:
		var new_button = button.duplicate()
		new_button.text = choice
		new_button.visible = true
		new_button.choice_id = ix
		new_button.connect("onPressedId", onChoiceClicked)
		vbox.add_child(new_button)
		choices[ix] = new_button
		ix += 1

func clearChoices():
	for k in choices:
		vbox.remove_child(choices[k])
	choices.clear()

func onChoiceClicked(id, text):
	choiceClicked.emit(id, text)

