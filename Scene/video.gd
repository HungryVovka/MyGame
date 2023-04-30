extends Control

@onready var textArea = $MarginContainer/TextArea
@onready var dialogManager = $DialogManager
@onready var audioManager = $AudioManager
@onready var fadebleBackground = $FadebleBackground

@export var clickable_background = false

func _ready():
	dialogManager.play_next_event()

func _process(_delta):
	pass

func _on_dialog_manager_end():
	textArea.resetCharacter()
	textArea.text = ""
	dialogManager.timeline = "res://timelines/testTimeline.json"
	dialogManager.play_next_event()

func _on_dialog_manager_reset_character():
	textArea.resetCharacter()

func _on_dialog_manager_update_character(portrait, character_name):
	textArea.setCharacter(portrait, character_name)

func _on_dialog_manager_update_text(text):
	textArea.text = text

func _on_text_area_on_next():
	dialogManager.play_next_event()

func _on_dialog_manager_set_background(res, fade_time):
	fadebleBackground.set_texture(res, fade_time)

func _on_fadeble_background_gui_input(event):
	if event is InputEventMouseButton && clickable_background && event.button_index == MOUSE_BUTTON_LEFT && event.pressed == true:
		dialogManager.play_next_event()

func _on_dialog_manager_set_background_clickable(value):
	clickable_background = value


func _on_dialog_manager_play_sound(name, channel, loop, bus, volume, fade):
	audioManager.play(name, channel, loop, bus, volume, fade)


func _on_dialog_manager_stop_sound(channel):
	audioManager.stop(channel)
