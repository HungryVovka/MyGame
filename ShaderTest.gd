extends Control
# Called when the node enters the scene tree for the first time.
@onready var rect = $TextureRect

@onready var bg = $FadebleBackground

func _ready():
	var animator = preload("res://shaders/AnimatedShader.gd")
	var shader = animator.new()
	shader.set_material(rect.material, "time")
	add_child(shader)
	
	#bg.set_background(load("res://Resources/Scene1/Art/3 (17).png"), true, {})
	
	bg.set_background(load("res://Resources/Scene1/Art/4.png"), true, { "blend": false, "blend_mode": false, "blend_speed": 0.5, "curtain_h": false, "curtain_reverse_h": false, "curtain_reverse_v": false, "curtain_speed_h": 0, "curtain_speed_v": 0, "curtain_v": false, "fade_color": "#000000ff", "fade_from": true, "fade_speed": 0.5, "fade_to": false, "scale_max": 1, "scale_min": 0, "scale_mode": false, "scale_shift": 1, "scale_speed": 0, "shake_h": false, "shake_height": 20, "shake_mode": false, "shake_speed": 0, "shake_time": 1, "shake_v": false, "slide_h": false, "slide_reverse": false, "slide_speed": 0, "slide_v": false, "swipe_max_h": 1920, "swipe_max_v": 1080, "swipe_min_h": -1920, "swipe_min_v": -1080, "swipe_mode_h": false, "swipe_mode_v": false, "swipe_shift_h": 0, "swipe_shift_v": 0, "swipe_speed_h": 0, "swipe_speed_v": 0 })
	
func _process(delta):
	pass

func _on_fadeble_background_gui_input(event):
	if event is InputEventMouseButton && event.pressed == true:		
		bg.set_background(load("res://Resources/Scene1/Art/4 (1).png"), true, { "blend": false, "blend_mode": false, "blend_speed": 1, "curtain_h": true, "curtain_reverse_h": false, "curtain_reverse_v": false, "curtain_speed_h": 0.5, "curtain_speed_v": 0, "curtain_v": false, "fade_color": "", "fade_from": false, "fade_speed": 0, "fade_to": false, "scale_max": 1, "scale_min": 0, "scale_mode": false, "scale_shift": 1, "scale_speed": 0, "shake_h": false, "shake_height": 20, "shake_mode": false, "shake_speed": 0, "shake_time": 1, "shake_v": false, "slide_h": false, "slide_reverse": false, "slide_speed": 0, "slide_v": false, "swipe_max_h": 1920, "swipe_max_v": 1080, "swipe_min_h": -1920, "swipe_min_v": -1080, "swipe_mode_h": false, "swipe_mode_v": false, "swipe_shift_h": 0, "swipe_shift_v": 0, "swipe_speed_h": 0, "swipe_speed_v": 0 })
