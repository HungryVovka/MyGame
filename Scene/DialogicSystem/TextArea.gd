extends Control

@export_multiline var text:  set =  setText, get = getText
@export var charactersPerSecond: int = 200
@export var nextOnClick: bool = true


@onready var richLabel = $GridContainer/MarginContainer/RichLabel
@onready var characterPortrait = $GridContainer/CharacterLine/CharacterTexture
@onready var characterName = $GridContainer/CharacterLine/CharacterName
@onready var clickSound = $ClickSound
@onready var typeSound = $GridContainer/MarginContainer/RichLabel/TypingSound

@export_file("*.wav", "*.ogg", "*.mp3") var typingSound: set = setTypingSound
@export_file("*.wav", "*.ogg", "*.mp3") var clickingSound: set = setClickingSound


signal on_text_clicked(event)
signal on_next()

var _text = ""
var _typingSoundValue
var _clickingSoundValue

func setTypingSound(value):
	if value && typeSound:
		typeSound.stream = load(value)
	if !typeSound:
		_typingSoundValue = value

func setClickingSound(value):
	if value && clickSound:
		clickSound.stream = load(value)
	if !clickSound:
		_clickingSoundValue = value

func setText(value):
	if richLabel:
		_update_rich_label(value, value.length() * 1.0 / charactersPerSecond)
	else:
		if value != null:
			_text = value
		
func getText():
	if richLabel:
		return richLabel.text
	else: 
		return ""

func _ready():
	if _text:
		_update_rich_label(_text, _text.length() * 1.0 / charactersPerSecond)
		_text = ""
	if _typingSoundValue:
		typeSound.stream = load(_typingSoundValue)
	if _clickingSoundValue:
		clickSound.stream = load(_clickingSoundValue)

func _update_rich_label(value, time):
	richLabel.set_text_animation(value, time)
	
func next():
	if richLabel.visible_ratio < 1.0:
		richLabel.visible_ratio = 1.0
	else:
		on_next.emit()

func setCharacter(portrait, character_name):
	characterPortrait.texture = portrait
	characterName.text = character_name

func resetCharacter():
	characterPortrait.texture = null
	characterName.text = ""

func _on_rich_label_gui_input(event):
	if event is InputEventMouseButton:
		on_text_clicked.emit(event)
		if nextOnClick && event.button_index == MOUSE_BUTTON_LEFT && event.pressed == true:
			clickSound.play()
			next()


