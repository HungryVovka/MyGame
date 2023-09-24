extends Control
# Called when the node enters the scene tree for the first time.
@onready var player = $AudioStreamPlayer

var tex: Texture2D = load("res://scenes/Res/loading_tex.png")

var textures = [
	load("res://Resources/Scene1/Art/1.png"),
	load("res://Resources/Scene1/Art/2.png"),
]

var index = 0

func _ready():
	$TextureRect2.texture = $SubViewport.get_texture()
	pass
	
func _process(delta):
	pass

func _on_button_pressed(): 
	$SubViewport/TextureRect.texture = textures[index]
	index = (index + 1) % textures.size()
