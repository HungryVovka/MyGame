extends Control

@onready var textArea = $MarginContainer/TextArea
@onready var dialogManager = $DialogManager
@onready var audioManager = $AudioManager
@onready var fadebleBackground = $FadebleBackground
@onready var choicesBlock = $ChoicesBlock
@onready var videoPlayer = $PanelContainer/VideoStreamPlayer
@onready var videoPanel = $PanelContainer

@onready var personLeft = $PersonTexture
@onready var personMiddleLeft = $PersonTexture2
@onready var personMiddle = $PersonTexture3
@onready var personMiddleRight = $PersonTexture4
@onready var personRight = $PersonTexture5

@export var clickable_background = false

func _ready():
	choicesBlock.visible = false
	dialogManager.timeline = "res://timelines/testTimeline.json"
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
	if !clickable_background && textArea.text == "":
		return
	if !choicesBlock.visible:
		dialogManager.play_next_event()

func _on_dialog_manager_set_background(res, fade_time):
	fadebleBackground.set_texture(res, fade_time)

func _on_fadeble_background_gui_input(event):
	if event is InputEventMouseButton \
		&& clickable_background \
		&& !choicesBlock.visible \
		&& event.button_index == MOUSE_BUTTON_LEFT \
		&& event.pressed == true:
		dialogManager.play_next_event()

func _on_dialog_manager_set_background_clickable(value):
	clickable_background = value


func _on_dialog_manager_play_sound(name, channel, loop, bus, volume, fade):
	audioManager.play(name, channel, loop, bus, volume, fade)


func _on_dialog_manager_stop_sound(channel):
	audioManager.stop(channel)


func _on_dialog_manager_show_choices(data):
	choicesBlock.set_choices(data)
	choicesBlock.visible = true


func _on_choices_block_choice_clicked(id):
	dialogManager.make_choice(id)
	if !dialogManager.is_choice:
		choicesBlock.visible = false



func _on_dialog_manager_play_video(res):
	videoPanel.visible = true
	videoPlayer.stop()
	videoPlayer.reset_image()
	videoPlayer.stream = res
	videoPlayer.play()


func _on_dialog_manager_stop_video():
	videoPanel.visible = false
	videoPlayer.stop()
	videoPlayer.reset_image()
