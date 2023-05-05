extends Node

@export_file("*.json") var timeline: set = setTimeline
@export_file("*.json") var character_list: set = setCharactersList
@export_file("*.json") var background_list: set = setBackgroundsList
@export_file("*.json") var videos_list: set = setVideosList

@export var dialog_state: Dictionary = {}

@export var is_choice = false

signal updateText(text)
signal updateCharacter(portrait, name)
signal resetCharacter()
signal end()
signal setBackground(res, fade_time)
signal setBackgroundClickable(value)

signal playSound(name, channel, loop, bus, volume, fade)
signal stopSound(channel)
signal showChoices(data)

signal playVideo(res)
signal stopVideo()

var text_data : Dictionary = {}
var characters_data : Dictionary = {}
var portraits_resources: Dictionary = {}
var videos_resources: Dictionary = {}
var background_resources: Dictionary = {}
var event_index_cache: Dictionary = {}

var current_index = [0]
var deep_index = 0

var current_event = null

var conditionManager



func reset_index():
	current_index = [0]
	deep_index = 0
	
func get_next_event():
	var evs = text_data
	var d = 0
	while d < deep_index:
		evs = evs.events[current_index[d]].choices[current_index[d+1]]
		d += 2
	var index = current_index[deep_index]
	if index >= evs.events.size():
		if deep_index > 0:
			current_index.remove_at(deep_index-1)
			current_index.remove_at(deep_index-1)
			deep_index -= 2
			current_index[deep_index] += 1
			return get_next_event()
		else:
			end.emit()
			return null
	return evs.events[index]
	
func jump_to(id):
	if event_index_cache.has(id):
		current_index = [] + event_index_cache[id]
		deep_index = current_index.size() - 1
		play_next_event()

func update_state(new_state: Dictionary = {}):
	for k in new_state:
		dialog_state[k] = new_state[k]
	
func make_choice(index, text):
	
	var found_index = 0
	var ci = 0
	for c in current_event.choices:
		if c.text == text:
			found_index = ci
			break
		ci += 1
	current_index.append(found_index)
	current_index.append(0)
	deep_index += 2
	play_next_event()
	
	
func setTimeline(filename):
	event_index_cache.clear()
	if filename:
		text_data = _read_json(filename)
		reset_index()
		create_event_index(text_data)
		

func create_event_index(e, prev: Array = []):
	var index = 0
	for event in e.events:
		if event.has("id"):
			var new_array = prev.duplicate()
			new_array.append(index)
			event_index_cache[event.id] = new_array
		if event.has("choices"):
			var cx = 0
			for choice in event.choices:
				var new_array = prev.duplicate()
				new_array.append(index)
				new_array.append(cx)
				create_event_index(choice, new_array)
				cx += 1
		index += 1

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

func setVideosList(filename):
	if filename: 
		videos_resources.clear()
		var data = _read_json(filename)
		for k in data.keys():
			videos_resources[k] = load(data[k])

func _read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data

func play_next_event():
	var event = get_next_event()
	current_event = event
	if event:
		if event.has("condition"):
			if !conditionManager.process(event.condition): 
				is_choice = false
				current_index[deep_index] += 1
				play_next_event()
				return
		if event.has("state"):
			process_state(event.state)
		if event.has("play_sound"):
			process_sound(event.play_sound)
		if event.has("stop_sound") && event.stop_sound != "":
			stopSound.emit(event.stop_sound)
		if event.has("jump_to"):
			jump_to(preprocess_string_to_state(event.jump_to))
			return
		updateText.emit(preprocess_string_to_state(event.text))
		if event.has("character"):
			process_character(event.character)
		if event.has("background"):
			process_background(event.background)
		if event.has("timer"):
			var timer = Timer.new()
			timer.one_shot = true
			add_child(timer)
			timer.connect("timeout", play_next_event)
			timer.start(event.timer)
		if event.has("choices"):
			process_choices(event.choices)
			is_choice = true
		else:
			current_index[deep_index] += 1
			is_choice = false

func _ready():
	conditionManager = preload("res://Scene/DialogicSystem/ConditionProcessor.gd").new()
	conditionManager.context = dialog_state
	add_child(conditionManager)
	pass 
	
func process_character(event):
	var character_name = preprocess_string_to_state(event)
	if characters_data.characters.has(character_name):
		var character = characters_data.characters[character_name]
		updateCharacter.emit(portraits_resources[character_name], 
			preprocess_string_to_state(character.name))
	else:
		resetCharacter.emit()

func process_background(event):
	var fade_time = event.fade if event.has("fade") else 0.0
	var bg_name = event.name if event.has("name") else ""
	bg_name = preprocess_string_to_state(bg_name)
	if background_resources.has(bg_name):
		setBackground.emit(background_resources[bg_name], fade_time)
	else:
		setBackground.emit(null, fade_time)
	if event.has("clickable"):
		setBackgroundClickable.emit(event.clickable)
	if event.has("video") && videos_resources.has(preprocess_string_to_state(event.video)):
		playVideo.emit(videos_resources[preprocess_string_to_state(event.video)])
	else:
		stopVideo.emit()

func process_sound(event):
	if event.has("name") && event.has("channel"):
		var _name = preprocess_string_to_state(event.name)
		var _channel = preprocess_string_to_state(event.channel)
		var loop = event.loop if event.has("loop") else false
		var bus = preprocess_string_to_state(event.bus) if event.has("bus") else "SFX"
		var volume = event.volume if event.has("volume") else 1.0
		var fade = event.fade if event.has("fade") else 0.0
		playSound.emit(_name, _channel, loop, bus, volume, fade)

func process_choices(event):
	var data = []
	for choice in event:
		if (choice.has("condition") && conditionManager.process(choice.condition)) or !choice.has("condition"):
			data.append(preprocess_string_to_state(choice.text))
	showChoices.emit(data)
	
func process_state(event):
	var dict = {}
	for k in event:
		dict[preprocess_string_to_state(k)] = preprocess_string_to_state(event[k])
	update_state(dict)
	
func preprocess_string_to_state(s: String):
	var result = s
	for k in dialog_state:
		result = result.replace("$(" + k + ")", dialog_state[k])
	return result
