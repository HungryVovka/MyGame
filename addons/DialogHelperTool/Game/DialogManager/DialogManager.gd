extends Node

@export_file("*.json") var timeline: set = setTimeline
@export_file("*.json") var character_list: set = setCharactersList
@export_file("*.json") var background_list: set = setBackgroundsList
@export_file("*.json") var videos_list: set = setVideosList

@export var is_choice = false

signal updateText(text)
signal updateCharacter(portrait, name)
signal resetCharacter()
signal end()
signal setBackground(res, has_trasnsition, transition_params)
signal setBackgroundClickable(value)

signal playSound(name, channel, loop, bus, volume, fade)
signal stopSound(channel)
signal showChoices(data)

signal playVideo(res)
signal stopVideo()


signal personVisible(name, isVisible)
signal personSource(name, src)
signal personAnimation(obj, type, animation, time, backwards)

var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()
var text_data : Dictionary = {}
var characters_data : Dictionary = {}
var portraits_resources: Dictionary = {}
var persons_resources: Dictionary = {}
var videos_resources: Dictionary = {}
var background_resources: Dictionary = {}
var event_index_cache: Dictionary = {}

var last_event = {}
var current_event = null
var nextEventTimer: Timer = null

var call_stack = []
var current_pos: Dictionary = {"index": 0, "root": ""}

func reset_index():
	current_pos = {"index": 0, "root": ""}
	call_stack.clear()
	
	if nextEventTimer:
		nextEventTimer.queue_free()
		nextEventTimer = null
	
func get_next_event():
	var evs = text_data.roots[current_pos.root] if current_pos.root != "" else text_data
	var index = current_pos.index
	if index >= evs.events.size():
		if !call_stack.is_empty():
			var prev = call_stack.pop_back()
			current_pos = JSONHelper.deep_duplicate(prev)
			current_pos.index += 1
			return get_next_event()
		else:
			print("END()")
			end.emit()
			return null
	return evs.events[index]
	
func jump_to(id):
	if event_index_cache[current_pos.root].has(id):
		current_pos = JSONHelper.deep_duplicate(event_index_cache[current_pos.root][id])
		play_next_event()
	elif text_data.roots.keys().has(id):
		call_stack.push_back(JSONHelper.deep_duplicate(current_pos))
		current_pos = {"index": 0, "root": id}
		play_next_event()
	
func make_choice(_index, text):
	var found_item = null
	if current_event == null:
		current_event = get_next_event()
	for c in current_event.choices.choices:
		if c.id == text:
			found_item = c
			break
	if found_item:
		jump_to(found_item.root)
	
func setTimeline(filename):
	event_index_cache.clear()
	if nextEventTimer:
		remove_child(nextEventTimer)
		nextEventTimer.stop()
		nextEventTimer.queue_free()
	
	current_event = null
	if filename:
		text_data = JSONHelper.read_json(filename, false)
		reset_index()
		create_event_index(text_data)

func create_event_index(e, prev: Array = []):
	var index = 0
	event_index_cache[""] = {}
	for event in e.events:
		if event.has("id"):
			event_index_cache[""][event.id] = {"index": index, "root": ""}
		index += 1
	for root in e.roots.keys():
		event_index_cache[root] = {}
		for ix in range(e.roots[root].events.size()):
			var event = e.roots[root].events[ix]
			if event.has("id"):
				event_index_cache[root][event.id] = {"index": ix, "root": root}

func setCharactersList(filename):
	if filename:
		portraits_resources.clear()
		characters_data = JSONHelper.read_json(filename, false)
		for k in characters_data.characters.keys():
			if characters_data.characters[k].portrait:
				portraits_resources[k] = load(characters_data.characters[k].portrait)
		persons_resources.clear()
		for k in characters_data.persons.keys():
			var res = {}
			for mood in characters_data.persons[k].keys():
				res[mood] = load(characters_data.persons[k][mood])
			persons_resources[k] = res

func setBackgroundsList(filename):
	if filename: 
		background_resources.clear()
		var data = JSONHelper.read_json(filename, false)
		for k in data.keys():
			background_resources[k] = load(data[k])

func setVideosList(filename):
	if filename: 
		videos_resources.clear()
		var data = JSONHelper.read_json(filename, false)
		for k in data.keys():
			videos_resources[k] = load(data[k])

func play_next_event():
	last_event = JSONHelper.deep_duplicate(current_pos)
	var event = get_next_event()
	current_event = event
	
	if nextEventTimer && !nextEventTimer.is_stopped() && event:
		nextEventTimer.stop()
	if event:
		if event.has("script"):
			if !process_script(event):
				is_choice = false
				current_pos.index += 1
				play_next_event()
				return
		if event.has("state"):
			process_state(event.state)
		if event.has("play_sound"):
			process_sound(event.play_sound)
		if event.has("stop_sound") && event.stop_sound != "":
			stopSound.emit(event.stop_sound)
		if event.has("persons"):
			process_persons(event.persons)
		if event.has("background"):
			process_background(event.background)
		if event.has("jump_to"):
			jump_to(DialogState.pps(event.jump_to))
			return
		updateText.emit(DialogState.pps(event.text))
		if event.has("character"):
			process_character(event.character)

		if event.has("timer"):
			if nextEventTimer:
				nextEventTimer.stop()
				nextEventTimer.queue_free()
				nextEventTimer = null
			nextEventTimer = Timer.new()
			nextEventTimer.one_shot = true
			add_child(nextEventTimer)
			nextEventTimer.connect("timeout", play_next_event)
			nextEventTimer.start(event.timer)
		if event.has("choices"):
			process_choices(event.choices)
			is_choice = true
		else:
			current_pos.index += 1
			is_choice = false

func _ready():
	pass 
	
func process_character(event):
	var character_name = DialogState.pps(event)
	if characters_data.characters.has(character_name):
		var character = characters_data.characters[character_name]
		
		updateCharacter.emit(portraits_resources[character_name] if portraits_resources.has(character_name) else null, 
			DialogState.pps(character.name))
	else:
		resetCharacter.emit()

func process_background(event):
	var has_transition = event.has("transition")
	var params = event.transition if has_transition else {}
	var bg_name = event.name if event.has("name") else ""
	bg_name = DialogState.pps(bg_name)
	if background_resources.has(bg_name):
		setBackground.emit(background_resources[bg_name], has_transition, params)
	else:
		setBackground.emit(null, has_transition, params)
	if event.has("clickable"):
		setBackgroundClickable.emit(event.clickable)
	if event.has("video") && videos_resources.has(DialogState.pps(event.video)):
		playVideo.emit(videos_resources[DialogState.pps(event.video)])
	else:
		stopVideo.emit()

func process_sound(event):
	if event.has("name") && event.has("channel"):
		var _name = DialogState.pps(event.name)
		var _channel = DialogState.pps(event.channel)
		var loop = event.loop if event.has("loop") else false
		var bus = DialogState.pps(event.bus) if event.has("bus") else "SFX"
		var volume = event.volume if event.has("volume") else 1.0
		var fade = event.fade if event.has("fade") else 0.0
		playSound.emit(_name, _channel, loop, bus, volume, fade)

func process_choices(event):
	var data = {
		"id": event.id,
		"choices": []
	}
	if event.has("scene"):
		data.scene = event.scene
	for choice in event.choices:
		if (choice.has("script") && process_script(choice)) or !choice.has("script"):
			data.choices.append(DialogState.pps(choice))
	showChoices.emit(data)
	
func process_state(event):
	DialogState.setState(event)


func process_persons(event):
	for p in event:
		if event[p].op == "Show":
			if persons_resources.has(event[p].person) && persons_resources[event[p].person].has(event[p].mood):
				personSource.emit(p, persons_resources[event[p].person][event[p].mood])
				personVisible.emit(p, true)
				if event[p].appear:
					personAnimation.emit(p, "dir", event[p].appearAnimation, event[p].appearTime, event[p].appearBackwards)
				if event[p].fade:
					personAnimation.emit(p, "fade", "", event[p].fadeTime, event[p].fadeBackwards)
				pass
			pass
		if event[p].op == "Hide":
			personVisible.emit(p, false)
	pass
	
func process_script(event):
	var txt = event.script if event.has("script") else event.condition if event.condition else ""
	var script = GDScript.new()
	script.source_code += "extends Node\n"
	script.source_code += txt
	script.reload()
	
	var obj = Node.new()
	obj.set_script(script)
	add_child(obj)
	var result = true
	if obj.has_method("condition"):
		result = obj.condition(self, event)
	if (result && obj.has_method("start")):
		obj.start(self, event)
	remove_child(obj)
	return result


func _on_text_area_event_reached(_name):
	if (!current_event.has("script") && !current_event.has("condition")):
		return
	var txt = current_event.script if current_event.has("script") else current_event.condition
	var script = GDScript.new()
	script.source_code += "extends Node\n"
	script.source_code += txt
	script.reload()
	
	var obj = Node.new()
	obj.set_script(script)
	add_child(obj)
	if obj.has_method(_name):
		obj.call(_name, self, current_event)
	remove_child(obj)
