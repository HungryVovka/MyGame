extends Control

var page = {}
var page_shift = 0
var current_page = ""

@onready var elements = [$GridContainer/El1, $GridContainer/El2, 
						$GridContainer/El3, $GridContainer/El4, 
						$GridContainer/El5, $GridContainer/El6]
@onready var pageButtons = [$Panel/Pages/p1, $Panel/Pages/p2, $Panel/Pages/p3,
							$Panel/Pages/p4, $Panel/Pages/p5, $Panel/Pages/p6,
							$Panel/Pages/p7, $Panel/Pages/p8, $Panel/Pages/p9]

@export var save_mode = false


signal save_clicked(page, num)
signal load_clicked(page, num)

func _ready():
	_represent("Q")
	
func render():
	_represent(current_page)

func _represent(page_id: String):
	current_page = page_id
	page = SaveManager.get_page(page_id)
	for i in 6:
		var iStr = str(i+1)
		if page.has(iStr):
			elements[i].loadSave(page[iStr])
		else:
			elements[i].loadSave({})	
	pass

func _update_page_buttons():
	for i in 9:
		pageButtons[i].text = str(page_shift + i + 1)

func _on_autosaves_pressed():
	_represent("A")

func _on_1_pressed():
	_represent(str(page_shift+1))

func _on_2_pressed():
	_represent(str(page_shift+2))

func _on_3_pressed():
	_represent(str(page_shift+3))

func _on_4_pressed():
	_represent(str(page_shift+4))

func _on_5_pressed():
	_represent(str(page_shift+5))

func _on_6_pressed():
	_represent(str(page_shift+6))

func _on_7_pressed():
	_represent(str(page_shift+7))

func _on_8_pressed():
	_represent(str(page_shift+8))

func _on_9_pressed():
	_represent(str(page_shift+9))

func _on_forward_pressed():
	page_shift += 9
	_update_page_buttons()


func _on_back_pressed():
	page_shift = max(page_shift - 9, 0)
	_update_page_buttons()

func el_clicked(num):
	if save_mode:
		save_clicked.emit(current_page, num)
	else:
		save_clicked.emit(current_page, num)

func _on_el_1_clicked():
	el_clicked("1")

func _on_el_2_clicked():
	el_clicked("2")

func _on_el_3_clicked():
	el_clicked("3")

func _on_el_4_clicked():
	el_clicked("4")

func _on_el_5_clicked():
	el_clicked("5")

func _on_el_6_clicked():
	el_clicked("6")


func _on_q_pressed():
	_represent("Q")
