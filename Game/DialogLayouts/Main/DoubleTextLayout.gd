extends "res://addons/DialogHelperTool/Game/DialogScene/DialogLayout.gd"

var lastCharacter:String = ""

func update_text(text):
	print(text," ", lastCharacter)
	if lastCharacter == "Captain":
		textArea[0].text = text
		textArea[1].text = ""
	else:
		textArea[1].text = text
		textArea[0].text = ""

func update_character(portrait, character_name):
	print("characterupdatras", character_name)
	if character_name == "Captain":
		textArea[0].setCharacter(portrait, character_name)
		textArea[1].resetCharacter()
	else:
		textArea[1].setCharacter(portrait, character_name)
		textArea[0].resetCharacter()
	lastCharacter = character_name




func _ready():
	super()
	dialogManager.disconnect("updateText", on_dialog_manager_update_text)
	dialogManager.disconnect("updateCharacter", on_dialog_manager_update_character)
	dialogManager.connect("updateCharacter", update_character)
	dialogManager.connect("updateText", update_text)


