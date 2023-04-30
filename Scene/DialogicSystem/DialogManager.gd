extends Node

@export_file("*.json") var timeline: set = setTimeline
@export_file("*.json") var character_list: set = setCharactersList
@export_file("*.json") var background_list: set = setBackgroundsList

signal updateText(text)
signal updateCharacter(portrait, name)
signal resetCharacter()
signal end()
signal setBackground(res, fade_time)
signal setBackgroundClickable(value)

signal playSound(name, channel, loop, bus, volume, fade)
signal stopSound(channel)

var text_data : Dictionary = {}
var characters_data : Dictionary = {}
var portraits_resources: Dictionary = {}
var background_resources: Dictionary = {}

var current_index = 0

var audio_players: Dictionary = {}
	
func setTimeline(filename):
	if filename:
		text_data = _read_json(filename)
		current_index = 0

func setCharactersList(filename):
	if filename:
		portraits_resources.clear()
		characters_data = _read_json(filename)
		for k in characters_data.characters.keys():
			portraits_resources[k] = load(characters_data.characters[k].portrait)

func setBackgroundsList(filename):
	if filename: 
		background_resources.clear()
		var data = _read_json(filename)
		for k in data.keys():
			background_resources[k] = load(data[k])

func _read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data

func play_next_event():
	if (current_index < text_data.events.size()):
		var event = text_data.events[current_index]
		updateText.emit(event.text)
		if event.has("character"):
			process_character(event.character)
		if event.has("background"):
			process_background(event.background)
		if event.has("play_sound"):
			process_sound(event.play_sound)
		if event.has("stop_sound") && event.stop_sound != "":
			stopSound.emit(event.stop_sound)
		current_index += 1
	else: 
		end.emit()

func _ready():
	pass 
	
func process_character(event):
	if characters_data.characters.has(event):
		var character = characters_data.characters[event]
		updateCharacter.emit(portraits_resources[event], character.name)
	else:
		resetCharacter.emit()

func process_background(event):
	var fade_time = event.fade if event.has("fade") else 0.0
	var bg_name = event.name if event.has("name") else ""
	if background_resources.has(bg_name):
		setBackground.emit(background_resources[bg_name], fade_time)
	else:
		setBackground.emit(null, fade_time)
	if event.has("clickable"):
		setBackgroundClickable.emit(event.clickable)

func process_sound(event):
	if event.has("name") && event.has("channel"):
		var loop = event.loop if event.has("loop") else false
		var bus = event.bus if event.has("bus") else "SFX"
		var volume = event.volume if event.has("volume") else 1.0
		var fade = event.fade if event.has("fade") else 0.0
		playSound.emit(event.name, event.channel, loop, bus, volume, fade)
	
