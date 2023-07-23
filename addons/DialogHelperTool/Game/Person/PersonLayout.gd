extends Control

@onready var persons: Dictionary = {
	"left": $PersonLeft,
	"middle-left": $PersonMiddleLeft,
	"middle": $PersonMiddle,
	"middle-right": $PersonMiddleRight,
	"right": $PersonRight
}

func set_person_source(obj: String, src):
	if persons.has(obj):
		persons[obj].setSource(src)

func set_person_visible(obj: String, v: bool):
	if persons.has(obj):
		persons[obj].setVisible(v)
		
func person_animation(obj: String, type: String = "dir", animation: String = "RESET", time: float = 1.0, backwards: bool = false):
	if persons.has(obj):
		match type:
			"dir":
				persons[obj].play_dir(animation, time, backwards)
			"fade":
				persons[obj].play_fade(time, backwards)
