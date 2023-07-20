extends Button

@onready var hoverSound = $Hover
@onready var clickSound = $Click

@export var choice_id: String
signal onPressedId(id, text)

func _on_pressed():
	clickSound.play()
	onPressedId.emit(choice_id, text)


func _on_mouse_entered():
	hoverSound.play()
