extends Control

signal on_next()

func _ready():
	$AnimationPlayer.play("appear1")


func _on_line_edit_text_changed(new_text):
	DialogState.s("player_name", new_text)

func _on_line_edit_text_submitted(new_text):
	$AnimationPlayer.play("disappear")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "disappear":
		on_next.emit()
