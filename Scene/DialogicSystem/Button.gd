extends Button

@onready var hoverSound = $Hover
@onready var clickSound = $Click

@export var choice_id: int
signal onPressedId(id)

func _on_pressed():
	clickSound.play()
	onPressedId.emit(choice_id)


func _on_mouse_entered():
	hoverSound.play()
