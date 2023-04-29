extends RichTextLabel


@onready var typingSound = $TypingSound

var _textTimer = Timer.new()
var _textAppearTime = 3.0
var _timerUpdateRate = 0.01


func _on_timer():
	var current_value = self.visible_ratio
	if current_value >= 1.0:
		_textTimer.stop()
		typingSound.stop()
	current_value += _timerUpdateRate / _textAppearTime
	if current_value >= 1.0:
		current_value = 1.0
	visible_ratio = current_value

func _ready():
	_textTimer.connect("timeout", _on_timer)
	add_child(_textTimer)

func _process(_delta):
	pass

func set_text_animation(text_value, time):
	self.text = text_value
	self.visible_ratio = 0.0
	_textAppearTime = time
	_textTimer.start(_timerUpdateRate)
	typingSound.play()
	pass

