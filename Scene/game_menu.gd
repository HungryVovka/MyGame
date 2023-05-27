extends Control

@onready var save = $Panel/SavePicker

signal savePicked(page, num)
signal loadPicked(page, num)


func _ready():
	pass # Replace with function body.

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")

func loadSaveRender():
	save.render()

func _on_save_pressed():
	save.save_mode = true
	save.visible = true
	save.render()


func _on_load_pressed():
	save.save_mode = false
	save.visible = true
	save.render()

func _on_settings_pressed():
	save.visible = false


func _on_credits_pressed():
	save.visible = false


func _on_quit_pressed():
	get_tree().quit()

func _on_save_picker_save_clicked(page, num):
	savePicked.emit(page, num)

func _on_save_picker_load_clicked(page, num):
	loadPicked.emit(page, num)
