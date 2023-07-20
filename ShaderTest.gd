extends Control
# Called when the node enters the scene tree for the first time.
@onready var rect = $TextureRect
@onready var player = $AudioStreamPlayer

func _ready():
	player.play(10.0)
	pass
	
func _process(delta):
	pass


func _on_button_pressed():
	$Button.text = str(player.get_playback_position())
