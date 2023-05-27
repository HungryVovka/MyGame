extends Node

const LoopableAudio = preload("res://Scene/DialogicSystem/LoopableAudio.gd")

var streams: Dictionary = {}
var players: Dictionary = {}
var tweens: Dictionary = {}

@export_file("*.json") var resources: set = setResources

func setResources(filename):
	if filename:
		players.clear()
		streams.clear()
		var data = _read_json(filename)
		for k in data.keys():
			streams[k] = load(data[k])
	pass

func play(_name, channel, loop = false, bus = "SFX", volume = 1.0, fade_in = 0.0):
	if (streams.has(_name)):
		if players.has(channel):
			players[channel].stop()
			players.erase(channel)
		
		var player = LoopableAudio.new()
		player.bus = bus
		player.stream = streams[_name]
		player.loop = loop
		player.volume_db = linear_to_db(volume)
		
		add_child(player)
		players[channel] = player
		
		if fade_in > 0.0:
			player.volume_db = linear_to_db(0.01)
			if tweens.has(channel):
				tweens[channel].kill()
				tweens.erase(channel)
			var tween = create_tween()
			tween.tween_property(player, "volume_db", linear_to_db(volume), fade_in)
		player.play()

func stop(channel):
	if players.has(channel):
		players[channel].stop()
		if tweens.has(channel):
			tweens[channel].kill()
			tweens.erase(channel)
		players.erase(channel)

func _read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data
