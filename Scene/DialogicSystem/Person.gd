extends Control

@onready var dirPlayer: AnimationPlayer = $Texture/DirectionPlayer
@onready var fadePlayer: AnimationPlayer = $Texture/FadePlayer
@onready var textureObj = $Texture
 
func setSource(filename):
	textureObj.texture = filename
	pass

func play_dir(name, time: float = 1.0, backwards: bool = false):
	dirPlayer.play(name, -1, 1.0 / time * -1.0 if backwards else 1.0 / time, backwards)
func play_fade(time: float = 1.0, backwards: bool = false):
	fadePlayer.play("fade", -1, 1.0 / time * -1.0 if backwards else 1.0 / time, backwards)

func reset():
	dirPlayer.play("RESET")
	fadePlayer.play("RESET")
	
func setVisible(v: bool = true):
	textureObj.visible = v
	
func setZ(type: String = "normal"):
	match type:
		"normal":
			z_index = 0
		"top":
			z_index = 1
		"behind":
			z_index = -2

func _ready():
	pass
