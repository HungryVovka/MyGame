extends Node

const LoopableAudio = preload("res://addons/DialogHelperTool/Game/AudioManager/LoopableAudio.gd")
var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()
var streams: Dictionary = {}
var players: Dictionary = {}
var tweens: Dictionary = {}
var cache: Dictionary = {}

@export_file("*.json") var resources: set = setResources

func setResources(filename):
	if filename:
		players.clear()
		streams.clear()
		var data = JSONHelper.read_json(filename, false)
		for k in data.keys():
			streams[k] = load(data[k])

func toJson() -> Array:
	var result = []
	for ch in players.keys():
		var player: LoopableAudio = players[ch]
		if player.playing:
			result.push_back({
				"request": JSONHelper.deep_duplicate(cache[ch]),
				"position": player.get_playback_position()
			})
	return result

func loadFromJson(data: Array):
	clear()
	for i in data:
		play(i.request.name, i.request.channel, i.request.loop, i.request.bus, i.request.volume, i.request.fade_in)
		players[i.request.channel].seek(i.position)

func play(_name, channel, loop = false, bus = "SFX", volume = 1.0, fade_in = 0.0):
	if (streams.has(_name)):
		cache[channel] = {
			"name": _name,
			"channel": channel,
			"loop": loop,
			"bus": bus,
			"volume": volume,
			"fade_in": fade_in
		}
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
		cache.erase(channel)

func clear():
	for ch in players.keys():
		stop(ch)
	players.clear()
	tweens.clear()
	cache.clear()
