extends Control

@onready var textArea = $PanelContainer/TextArea

var text_data : Dictionary = {}

var current_index = 0


func read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var json_object = JSON.new()
	var parse_err = json_object.parse_string(txt)
	file.close()
	return parse_err
	
	
func play_next_event():
	if (current_index < text_data.events.size()):
		textArea.text = text_data.events[current_index].text
		current_index += 1
	else: 
		textArea.text = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	text_data = read_json("res://timelines/testTimeline.json")
	play_next_event()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
