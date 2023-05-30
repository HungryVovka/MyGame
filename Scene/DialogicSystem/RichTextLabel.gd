extends RichTextLabel


@onready var typingSound = $TypingSound
signal event_reached(name)

var _textTimer = Timer.new()
var _textAppearTime = 5.0
var _timerUpdateRate = 0.01
var _pauses = []
var _events = []
var is_paused = false

func _on_timer():
	var current_value = self.visible_ratio
	if current_value >= 1.0:
		_textTimer.stop()
		typingSound.stop()
	current_value += _timerUpdateRate / _textAppearTime
	if current_value >= 1.0:
		current_value = 1.0
	visible_ratio = current_value
	
	var nextEvent = null if _events.size() == 0 else _events[0].index
	if _events.size() > 0 && (visible_characters == -1 || visible_characters > nextEvent):
		event_reached.emit(_events.pop_front().name)
		
	var nextBreak = null if _pauses.size() == 0 else _pauses[0]
	if _pauses.size() > 0 && (visible_characters == -1 || visible_characters > nextBreak):
		_textTimer.stop()
		_pauses.pop_front()
		is_paused = true
	
func next():
	if is_paused:
		is_paused = false
		_textTimer.start(_timerUpdateRate)
		return false
	else:
		if visible_ratio < 1.0:
			visible_ratio = 1.0
			return false
		else:
			return true

func _ready():
	_textTimer.connect("timeout", _on_timer)
	add_child(_textTimer)

func _process(_delta):
	pass

func set_text_animation(text_value: String, time):
	_update_text(text_value)
	_textAppearTime = time
	_textTimer.start(_timerUpdateRate)
	if text_value != "":
		typingSound.play()
	pass

func _update_text(value: String):
	var skip_index = value.find("{>>}")
	var s = value.replace("{>>}", "")
	if skip_index >= 0:
		self.visible_ratio = skip_index * 1.0 / s.length()
	else:
		self.visible_ratio = 0.0
	_pauses = []
	_events = []
	
	var stripped = _strip_events_from_string(s)
	
	while s.contains("{||}"):
		var ix = stripped.find("{||}")
		_pauses.push_back(ix)
		s = _remove_first(s, "{||}")
		stripped = _remove_first(stripped, "{||}")
		
	var regex = RegEx.new()
	regex.compile("{:\\S{1,}}")
	var res = regex.search(s)
	while res:
		var event_name = res.get_string()
		_events.push_back({"index": s.find(event_name), "name": event_name.replace("{:", "").replace("}", "")})
		s = _remove_first(s, event_name)
		res = regex.search(s)
	self.text = s
	
func _strip_events_from_string(s):
	var newS = s
	var regex = RegEx.new()
	regex.compile("{:\\S{1,}}")
	var res = regex.search(newS)
	while res:
		newS = _remove_first(newS, res.get_string())
		res = regex.search(newS)
	return newS
		
func _remove_first(string: String, removal: String):
	var length = removal.length()
	var i = 0
	while i < string.length() - length:
		var piece = ''
		var j = i
		while j < i + length:
			piece += string[j]
			j += 1
		if piece == removal:
			return string.substr(0, j - length) + string.substr(j)
		i += 1
	return string


func _on_meta_clicked(_meta):
	pass # Replace with function body.
