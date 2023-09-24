extends Control

signal on_next()

@onready var jessica = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var katie = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/LineEdit2
@onready var lisa = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/LineEdit3

func _ready():
	fadeIn()
	
func fadeIn():
	$AnimationPlayer.play("appear")

func _on_line_edit_text_changed(new_text):
	DialogState.s("jessica_relation", new_text)

func _on_line_edit_2_text_changed(new_text):
	DialogState.s("katie_relation", new_text)

func _on_line_edit_3_text_changed(new_text):
	DialogState.s("lisa_relation", new_text)

func _on_button_pressed():
	_on_line_edit_text_changed(jessica.text)
	_on_line_edit_2_text_changed(katie.text)
	_on_line_edit_3_text_changed(lisa.text)
	$AnimationPlayer.play("disappear")
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "disappear":
		on_next.emit()


func _on_gui_input(event):
	pass # Replace with function body.


func _on_line_edit_3_gui_input(event):
	pass # Replace with function body.
