extends AudioStreamPlayer
@export var loop = false

func _ready():
	self.connect("finished", _on_finished)
func _on_finished():
	if loop:
		play();
