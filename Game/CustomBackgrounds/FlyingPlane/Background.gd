extends ParallaxBackground

@onready var plane = $Sprite2D
@onready var bg = $ParallaxLayer/Sprite2D
@onready var player = $AnimationPlayer
var textures = [
	load("res://Game/CustomBackgrounds/FlyingPlane/assets/00022-3017643196.png"), 
	load("res://Game/CustomBackgrounds/FlyingPlane/assets/00051-2133317833.png"),
	load("res://Game/CustomBackgrounds/FlyingPlane/assets/00085-20282181.png"),
	load("res://Game/CustomBackgrounds/FlyingPlane/assets/00094-3795384612.png")
	]
var current_index = 1
var plane_init_pos: Vector2 = Vector2(0, 0)

@export var whiteness: float = 0.0: set = setWhiteness


func setWhiteness(v):
	if !is_node_ready():
		await ready
	bg.material.set_shader_parameter("whiteness_level", v)
	whiteness = v

func _ready():
	plane_init_pos = Vector2(plane.position)

func _process(delta):
	scroll_offset.x -= 400 * delta
	scroll_offset.y += 100 * delta
	if is_node_ready():
		plane.position = plane_init_pos + Vector2(sin(scroll_offset.x / 500.)*25.0, -cos(scroll_offset.y/500.)*20.0)

func on_texture_button_pressed():
	if !player.is_playing():
		player.play("to_white")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "to_white":
		current_index = (current_index + 1) % textures.size()
		bg.texture = textures[current_index]
		player.play("to_normal")
