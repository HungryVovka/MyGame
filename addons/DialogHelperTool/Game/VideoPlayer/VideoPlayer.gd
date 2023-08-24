extends Control

@onready var player = $VideoStreamPlayer
@onready var videoFrame = $VideoFrame
@onready var overlay = $Overlay
var dialog_tool_type: String = "VIDEOPLAYER"

func _ready():
	videoFrame.texture = player.get_video_texture()

func play(res):
	player.stop()
	player.reset_image()
	player.set_process(true)
	player.stream = res
	player.play()

func stop():
	player.stop()
	player.reset_image()
	overlay.material = null
