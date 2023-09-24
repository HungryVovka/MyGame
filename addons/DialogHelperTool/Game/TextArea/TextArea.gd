extends Control

@export_multiline var text:  set =  setText, get = getText
@export var charactersPerSecond: int = 200
@export var nextOnClick: bool = true
@export var character:String ="":set =  setCharacterProp, get = getCharacterProp

@onready var richLabel = $VBoxContainer/Control/TextureRect/MarginContainer/RichLabel
@onready var characterPortrait = $VBoxContainer/CharacterLine/CharacterTexture
@onready var characterName = $VBoxContainer/CharacterLine/CharacterName
@onready var clickSound = $ClickSound
@onready var typeSound = $VBoxContainer/Control/TextureRect/MarginContainer/RichLabel/TypingSound
@onready var rect = $VBoxContainer/Control/TextureRect

@export_file("*.wav", "*.ogg", "*.mp3") var typingSound: set = setTypingSound
@export_file("*.wav", "*.ogg", "*.mp3") var clickingSound: set = setClickingSound

var current_meta = null
var dialog_tool_type: String = "TEXT_AREA"


signal on_text_clicked(event)
signal on_next()
signal event_reached(name)

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
		rect.modulate = Color.WHITE if value != "" else Color.TRANSPARENT
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
	if richLabel.next():
		on_next.emit()

func setCharacterProp(value:String):
	character = value
	characterName.text = value

func getCharacterProp():
	return character

func setCharacter(portrait, character_name):
	characterPortrait.texture = portrait
	setCharacterProp(character_name)

func resetCharacter():
	characterPortrait.texture = null
	setCharacterProp("")

func _on_rich_label_gui_input(event):
	if event is InputEventMouseButton:
		if current_meta && event.button_index == MOUSE_BUTTON_LEFT && event.pressed == true:
			event_reached.emit(current_meta)
			return
		on_text_clicked.emit(event)
		if (nextOnClick || richLabel.is_paused) && event.button_index == MOUSE_BUTTON_LEFT && event.pressed == true:
			clickSound.play()
			next()

func _on_rich_label_event_reached(n):
	event_reached.emit(n)


func _on_rich_label_meta_hover_started(meta):
	current_meta = meta


func _on_rich_label_meta_hover_ended(_meta):
	current_meta = null

