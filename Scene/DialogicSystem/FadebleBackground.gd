extends Control

@onready var first = $First
@onready var second = $Second

var tween

var is_first = true

func animateBackground(from, to, time): 
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(from, "modulate", Color.TRANSPARENT, time)
	tween.tween_property(to, "modulate", Color.WHITE, time)

func clear():
	first.texture = null
	second.texture = null

func set_texture(res, fade_time):
	if fade_time == 0.0:
		if is_first:
			first.texture = res
			first.modulate = Color.WHITE
		else:
			second.texture = res
			second.modulate = Color.WHITE
	else:
		if is_first:
			second.texture = res
			animateBackground(first, second, fade_time)
			is_first = false
		else:
			first.texture = res
			animateBackground(second, first, fade_time)
			is_first = true
