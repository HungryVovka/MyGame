extends RichTextLabel


var _textTimer = Timer.new()
var _textAppearTime = 3.0
var _timerUpdateRate = 0.01


func _on_timer():
	var current_value = self.visible_ratio
	if current_value >= 1.0:
		_textTimer.stop()
	current_value += _timerUpdateRate / _textAppearTime
	if current_value >= 1.0:
		current_value = 1.0
	visible_ratio = current_value

# Called when the node enters the scene tree for the first time.
func _ready():
	_textTimer.connect("timeout", _on_timer)
	add_child(_textTimer)
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_text_animation(text, time):
	self.text = text
	self.visible_ratio = 0.0
	_textAppearTime = time
	_textTimer.start(_timerUpdateRate)
	pass

