@tool
extends Control


@export var src: Dictionary: set = setSource

@onready var enabled_checkbox = $MarginContainer/ScrollContainer/VBoxContainer/TransitionCheckbox
@onready var swipe_button = $MarginContainer/ScrollContainer/VBoxContainer/SwipeButton
@onready var swipe_h = $MarginContainer/ScrollContainer/VBoxContainer/SwipeHBox/MarginContainer/SwipeHorizontalCheckbox
@onready var swipe_h_speed= $MarginContainer/ScrollContainer/VBoxContainer/SwipeHBox/SwipeHSpeed
@onready var swipe_h_min = $MarginContainer/ScrollContainer/VBoxContainer/SwipeHBox/SwipeMinH
@onready var swipe_h_max = $MarginContainer/ScrollContainer/VBoxContainer/SwipeHBox/SwipeMaxH
@onready var swipe_h_shift = $MarginContainer/ScrollContainer/VBoxContainer/SwipeHBox/SwipeOffsetH

@onready var swipe_v = $MarginContainer/ScrollContainer/VBoxContainer/SwipeVBox/MarginContainer/SwipeVerticalCheckbox
@onready var swipe_v_speed = $MarginContainer/ScrollContainer/VBoxContainer/SwipeVBox/SwipeVSpeed
@onready var swipe_v_min = $MarginContainer/ScrollContainer/VBoxContainer/SwipeVBox/SwipeMinV
@onready var swipe_v_max = $MarginContainer/ScrollContainer/VBoxContainer/SwipeVBox/SwipeMaxV
@onready var swipe_v_shift = $MarginContainer/ScrollContainer/VBoxContainer/SwipeVBox/SwipeOffsetV

@onready var scale_button = $MarginContainer/ScrollContainer/VBoxContainer/ScaleButton
@onready var scale_enabled = $MarginContainer/ScrollContainer/VBoxContainer/ScaleHBox/MarginContainer/SwipeHorizontalCheckbox
@onready var scale_speed = $MarginContainer/ScrollContainer/VBoxContainer/ScaleHBox/ScaleHSpeed
@onready var scale_min = $MarginContainer/ScrollContainer/VBoxContainer/ScaleHBox/SwipeMinH
@onready var scale_max = $MarginContainer/ScrollContainer/VBoxContainer/ScaleHBox/SwipeMaxH
@onready var scale_offset = $MarginContainer/ScrollContainer/VBoxContainer/ScaleHBox/SwipeOffsetH

@onready var shake_button = $MarginContainer/ScrollContainer/VBoxContainer/ShakeButton
@onready var shake_h = $MarginContainer/ScrollContainer/VBoxContainer/ShakeHBox/MarginContainer/ShakeH
@onready var shake_v = $MarginContainer/ScrollContainer/VBoxContainer/ShakeHBox/ShakeV
@onready var shake_speed = $MarginContainer/ScrollContainer/VBoxContainer/ShakeHBox/ShakeHSpeed
@onready var shake_height = $MarginContainer/ScrollContainer/VBoxContainer/ShakeHBox/ShakeSize
@onready var shake_time = $MarginContainer/ScrollContainer/VBoxContainer/ShakeHBox/ShakeTime

@onready var blend_button = $MarginContainer/ScrollContainer/VBoxContainer/BlendButton
@onready var blend_enabled = $MarginContainer/ScrollContainer/VBoxContainer/BlendHBox/MarginContainer/BlendEnabled
@onready var blend_speed = $MarginContainer/ScrollContainer/VBoxContainer/BlendHBox/BlendSpeed

@onready var fade_button = $MarginContainer/ScrollContainer/VBoxContainer/FadeButton
@onready var fade_from = $MarginContainer/ScrollContainer/VBoxContainer/FadeHBox/MarginContainer/FadeFrom
@onready var fade_to = $MarginContainer/ScrollContainer/VBoxContainer/FadeHBox/FadeTo
@onready var fade_speed = $MarginContainer/ScrollContainer/VBoxContainer/FadeHBox/FadeSpeed
@onready var fade_color = $MarginContainer/ScrollContainer/VBoxContainer/FadeHBox/ColorPickerButton

@onready var slide_button = $MarginContainer/ScrollContainer/VBoxContainer/SlideButton
@onready var slide_h = $MarginContainer/ScrollContainer/VBoxContainer/SlideHBox/MarginContainer/SlideHCheckbox
@onready var slide_v = $MarginContainer/ScrollContainer/VBoxContainer/SlideHBox/SlideVCheckbox
@onready var slide_reverse = $MarginContainer/ScrollContainer/VBoxContainer/SlideHBox/SlideReverse
@onready var slide_speed = $MarginContainer/ScrollContainer/VBoxContainer/SlideHBox/SlideSpeed

@onready var curtain_button = $MarginContainer/ScrollContainer/VBoxContainer/CurtainButton
@onready var curtain_h = $MarginContainer/ScrollContainer/VBoxContainer/CurtainHBox/MarginContainer/CurtainHCheckbox
@onready var curtain_v = $MarginContainer/ScrollContainer/VBoxContainer/CurtainHBox/CurtainVCheckbox
@onready var curtain_h_reverse = $MarginContainer/ScrollContainer/VBoxContainer/CurtainHBox/CurtainHReverse
@onready var curtain_v_reverse = $MarginContainer/ScrollContainer/VBoxContainer/CurtainHBox/CurtainVReverse
@onready var curtain_h_speed = $MarginContainer/ScrollContainer/VBoxContainer/CurtainHBox/SwipeHSpeed
@onready var curtain_v_speed = $MarginContainer/ScrollContainer/VBoxContainer/CurtainHBox/SwipeVSpeed

@onready var swipe_box_h = $MarginContainer/ScrollContainer/VBoxContainer/SwipeHBox
@onready var swipe_box_v = $MarginContainer/ScrollContainer/VBoxContainer/SwipeVBox
@onready var scale_box = $MarginContainer/ScrollContainer/VBoxContainer/ScaleHBox
@onready var shake_box = $MarginContainer/ScrollContainer/VBoxContainer/ShakeHBox
@onready var blend_box = $MarginContainer/ScrollContainer/VBoxContainer/BlendHBox
@onready var fade_box = $MarginContainer/ScrollContainer/VBoxContainer/FadeHBox
@onready var slide_box = $MarginContainer/ScrollContainer/VBoxContainer/SlideHBox
@onready var curtain_box = $MarginContainer/ScrollContainer/VBoxContainer/CurtainHBox

@onready var block = $MarginContainer/MarginContainer

var _data_ready = false

var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()


func setSource(s: Dictionary):
	_data_ready = false
	src = s
	if s.has("transition"):
		enabled_checkbox.button_pressed = true
		_on_transition_checkbox_toggled(true)
	else:
		enabled_checkbox.button_pressed = false
		_on_transition_checkbox_toggled(false)
	
	_on_swipe_button_toggled(false)
	swipe_button.button_pressed = false
	_on_scale_button_toggled(false)
	scale_button.button_pressed = false
	_on_shake_button_toggled(false)
	shake_button.button_pressed = false
	_on_blend_button_toggled(false)
	blend_button.button_pressed = false
	_on_fade_button_toggled(false)
	fade_button.button_pressed = false
	_on_slide_button_toggled(false)
	slide_button.button_pressed = false
	_on_curtain_button_toggled(false)
	curtain_button.button_pressed = false
	
	if s.has("transition"):
		var t = s.transition
		if JSONHelper.gb(t, ["swipe_mode_h"]):
			_on_swipe_button_toggled(true)
			swipe_button.button_pressed = true
			swipe_h.button_pressed = true
			swipe_h_speed.value = t.swipe_speed_h
			swipe_h_min.value = t.swipe_min_h
			swipe_h_max.value = t.swipe_max_h
			swipe_h_shift.value = t.swipe_shift_h
		else:
			swipe_h.button_pressed = false
			swipe_h_speed.value = 0
			swipe_h_min.value = -1920
			swipe_h_max.value = 1920
			swipe_h_shift.value = 0
		if JSONHelper.gb(t, ["swipe_mode_v"]):
			_on_swipe_button_toggled(true)
			swipe_button.button_pressed = true
			
			swipe_v.button_pressed = true
			swipe_v_speed.value = t.swipe_speed_v
			swipe_v_min.value = t.swipe_min_v
			swipe_v_max.value = t.swipe_max_v
			swipe_v_shift.value = t.swipe_shift_v
		else:
			swipe_v.button_pressed = false
			swipe_v_speed.value = 0
			swipe_v_min.value = -1080
			swipe_v_max.value = 1080
			swipe_v_shift.value = 0
		if JSONHelper.gb(t, ["scale_mode"]):
			_on_scale_button_toggled(true)
			scale_button.button_pressed = true
			scale_enabled.button_pressed = true
			scale_speed.value = t.scale_speed
			scale_min.value = t.scale_min
			scale_max.value = t.scale_max
			scale_offset.value = t.scale_shift
		else:
			scale_enabled.button_pressed = false
			scale_speed.value = 0
			scale_min.value = 0
			scale_max.value = 1.0
			scale_offset.value = 0.0
		if JSONHelper.gb(t, ["shake_mode"]):
			_on_shake_button_toggled(true)
			shake_button.button_pressed = true
			shake_h.button_pressed = JSONHelper.gb(t, ["shake_h"])
			shake_v.button_pressed = JSONHelper.gb(t, ["shake_v"])
			shake_speed.value = t.shake_speed
			shake_time.value = t.shake_time
			shake_height.value = t.shake_height
		else:
			shake_h.button_pressed = false
			shake_v.button_pressed = false
			shake_speed.value = 1.0
			shake_time.value = 1.0
			shake_height.value = 0.0
		if JSONHelper.gb(t, ["blend_mode", "blend"]):
			_on_blend_button_toggled(true)
			blend_button.button_pressed = true
			blend_enabled.button_pressed = true
			blend_speed.value = t.blend_speed
		else:
			blend_enabled.button_pressed = false
			blend_speed.value = 1.0
		if JSONHelper.gb(t, ["fade_to", "fade_from"]):
			_on_fade_button_toggled(true)
			fade_button.button_pressed = true
			fade_to.button_pressed = JSONHelper.gb(t, ["fade_to"])
			fade_from.button_pressed = JSONHelper.gb(t, ["fade_from"])
			fade_speed.value = t.fade_speed
			fade_color.color = Color.from_string(t.fade_color, Color.BLACK)
		else:
			fade_to.button_pressed = false
			fade_from.button_pressed = false
			fade_speed.value = 1.0
			fade_color.color = Color.BLACK
		if JSONHelper.gb(t, ["slide_h", "slide_v"]):
			_on_slide_button_toggled(true)
			slide_button.button_pressed = true
			slide_h.button_pressed = JSONHelper.gb(t, ["slide_h"])
			slide_v.button_pressed = JSONHelper.gb(t, ["slide_v"])
			slide_speed.value = t.slide_speed
			slide_reverse.button_pressed = t.slide_reverse
		else:
			slide_h.button_pressed = false
			slide_v.button_pressed = false
			slide_speed.value = 0.05
			slide_reverse.button_pressed = false

		if JSONHelper.gb(t, ["curtain_h"]):
			_on_curtain_button_toggled(true)
			curtain_button.button_pressed = true
			curtain_h.button_pressed = JSONHelper.gb(t, ["curtain_h"])
			curtain_h_speed.value = t.curtain_speed_h
			curtain_h_reverse.button_pressed = t.curtain_reverse_h
		else:
			curtain_h.button_pressed = false
			curtain_h_speed.value = 0.0
			curtain_h_reverse.button_pressed = false
		if JSONHelper.gb(t, ["curtain_v"]):
			_on_curtain_button_toggled(true)
			curtain_button.button_pressed = true
			curtain_v.button_pressed = JSONHelper.gb(t, ["curtain_v"])
			curtain_v_speed.value = t.curtain_speed_v
			curtain_v_reverse.button_pressed = t.curtain_reverse_v
		else:
			curtain_v.button_pressed = false
			curtain_v_speed.value = 0.0
			curtain_v_reverse.button_pressed = false
	_data_ready = true
			
func _ready():
	block.add_theme_constant_override("margin_top", enabled_checkbox.size.y)

func _on_swipe_button_toggled(button_pressed):
	swipe_box_h.visible = button_pressed
	swipe_box_v.visible = button_pressed

func _on_scale_button_toggled(button_pressed):
	scale_box.visible = button_pressed

func _on_shake_button_toggled(button_pressed):
	shake_box.visible = button_pressed

func _on_blend_button_toggled(button_pressed):
	blend_box.visible = button_pressed

func _on_fade_button_toggled(button_pressed):
	fade_box.visible = button_pressed

func _on_slide_button_toggled(button_pressed):
	slide_box.visible = button_pressed

func _on_curtain_button_toggled(button_pressed):
	curtain_box.visible = button_pressed

func _on_transition_checkbox_toggled(button_pressed):
	block.visible = !button_pressed
	if _data_ready:
		if !button_pressed:
			src.erase("transition")
		else:
			src.transition = {}
			_on_swipe_horizontal_checkbox_toggled(swipe_h.button_pressed)
			_on_swipe_vertical_checkbox_toggled(swipe_v.button_pressed)
			_on_scale_checkbox_toggled(scale_enabled.button_pressed)
			_on_shake_h_toggled(shake_h.button_pressed)
			_on_shake_v_toggled(shake_v.button_pressed)
			_on_blend_enabled_toggled(blend_enabled.button_pressed)
			_on_fade_from_toggled(fade_from.button_pressed)
			_on_fade_to_toggled(fade_to.button_pressed)
			_on_slide_h_checkbox_toggled(slide_h.button_pressed)
			_on_slide_v_checkbox_toggled(slide_v.button_pressed)
			_on_curtain_h_checkbox_toggled(curtain_h.button_pressed)
			_on_curtain_v_checkbox_toggled(curtain_v.button_pressed)


func _on_swipe_horizontal_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	if button_pressed:
		t.swipe_mode_h = true
		t.swipe_speed_h = swipe_h_speed.value
		t.swipe_min_h = swipe_h_min.value
		t.swipe_max_h = swipe_h_max.value
		t.swipe_shift_h = swipe_h_shift.value
	else:
		t.erase("swipe_mode_h")
		t.erase("swipe_speed_h")
		t.erase("swipe_min_h")
		t.erase("swipe_max_h")
		t.erase("swipe_shift_h")


func _on_swipe_h_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["swipe_mode_h"]):
		t.swipe_speed_h = value


func _on_swipe_min_h_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["swipe_mode_h"]):
		t.swipe_min_h = value


func _on_swipe_max_h_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["swipe_mode_h"]):
		t.swipe_max_h = value


func _on_swipe_offset_h_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["swipe_mode_h"]):
		t.swipe_shift_h = value


func _on_swipe_vertical_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	if button_pressed:
		t.swipe_mode_v = true
		t.swipe_speed_v = swipe_v_speed.value
		t.swipe_min_v = swipe_v_min.value
		t.swipe_max_v = swipe_v_max.value
		t.swipe_shift_v = swipe_v_shift.value
	else:
		t.erase("swipe_mode_v")
		t.erase("swipe_speed_v")
		t.erase("swipe_min_v")
		t.erase("swipe_max_v")
		t.erase("swipe_shift_v")


func _on_swipe_v_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["swipe_mode_v"]):
		t.swipe_speed_v = value


func _on_swipe_min_v_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["swipe_mode_v"]):
		t.swipe_min_v = value


func _on_swipe_max_v_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["swipe_mode_v"]):
		t.swipe_max_v = value


func _on_swipe_offset_v_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["swipe_mode_v"]):
		t.swipe_shift_v = value


func _on_scale_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	if button_pressed:
		t.scale_mode = true
		t.scale_speed = scale_speed.value
		t.scale_min = scale_min.value
		t.scale_max = scale_max.value
		t.scale_shift = scale_offset.value
	else:
		t.erase("scale_mode")
		t.erase("scale_speed")
		t.erase("scale_min")
		t.erase("scale_max")
		t.erase("scale_shift")


func _on_scale_h_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["scale_mode"]):
		t.scale_speed = value


func _on_scale_min_h_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["scale_mode"]):
		t.scale_min = value


func _on_scale_max_h_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["scale_mode"]):
		t.scale_max = value


func _on_scale_offset_h_value_changed(value):
	
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["scale_mode"]):
		t.scale_shift = value


func _on_shake_h_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	t.shake_h = button_pressed
	restore_shake()
	
func restore_shake():
	var t: Dictionary = src.transition
	var shake_enabled = JSONHelper.gb(t, ["shake_v", "shake_h"])
	if shake_enabled:
		t.shake_mode = true
		t.shake_speed = shake_speed.value
		t.shake_height = shake_height.value
		t.shake_time = shake_time.value
	else:
		t.erase("shake_mode")
		t.erase("shake_h")
		t.erase("shake_v")
		t.erase("shake_speed")
		t.erase("shake_height")
		t.erase("shake_time")
		


func _on_shake_v_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	t.shake_v = button_pressed
	restore_shake()


func _on_shake_h_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["shake_v", "shake_h"]) && JSONHelper.gb(t, ["shake_mode"]):
		t.shake_speed = value


func _on_shake_size_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["shake_v", "shake_h"]) && JSONHelper.gb(t, ["shake_mode"]):
		t.shake_height = value


func _on_shake_time_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["shake_v", "shake_h"]) && JSONHelper.gb(t, ["shake_mode"]):
		t.shake_time = value


func _on_blend_enabled_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	if button_pressed:
		t.blend = true
		t.blend_mode = true
		t.blend_speed = blend_speed.value
	else:
		t.erase("blend")
		t.erase("blend_mode")
		t.erase("blend_speed")


func _on_blend_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["blend_mode"]):
		t.blend_speed = value


func _on_fade_from_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	t.fade_from = button_pressed
	restore_fade()


func _on_fade_to_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	t.fade_to = button_pressed
	restore_fade()
	
func restore_fade():
	var t: Dictionary = src.transition
	var fade_enabled = JSONHelper.gb(t, ["fade_to", "fade_from"])
	if fade_enabled:
		t.fade_speed = shake_speed.value
		t.fade_color = "#" + Color(fade_color.color).to_html()
	else:
		t.erase("fade_to")
		t.erase("fade_from")
		t.erase("fade_speed")
		t.erase("fade_color")


func _on_fade_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["fade_to", "fade_from"]):
		t.fade_speed = value
		
func _on_color_picker_button_color_changed(color: Color):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["fade_to", "fade_from"]):
		t.fade_color = "#" + color.to_html()
		
func _on_slide_h_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	t.slide_h = button_pressed
	restore_slide()


func _on_slide_v_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	t.slide_v = button_pressed
	restore_slide()
	
func restore_slide():
	var t: Dictionary = src.transition
	var slide_enabled = JSONHelper.gb(t, ["slide_h", "slide_v"])
	if slide_enabled:
		t.slide_reverse = slide_reverse.button_pressed
		t.slide_speed = slide_speed.value
	else:
		t.erase("slide_h")
		t.erase("slide_v")
		t.erase("slide_speed")
		t.erase("slide_reverse")

func _on_slide_reverse_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["slide_h", "slide_v"]):
		t.slide_reverse = button_pressed
		

func _on_slide_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["slide_h", "slide_v"]):
		t.slide_speed = value
		
func restore_curtain_h():
	var t: Dictionary = src.transition
	var enabled = JSONHelper.gb(t, ["curtain_h"])
	if enabled:
		t.curtain_speed_h = curtain_h_speed.value
		t.curtain_reverse_h = curtain_h_reverse.button_pressed
	else:
		t.erase("curtain_h")
		t.erase("curtain_speed_h")
		t.erase("curtain_reverse_h")
		
func restore_curtain_v():
	var t: Dictionary = src.transition
	var enabled = JSONHelper.gb(t, ["curtain_v"])
	if enabled:
		t.curtain_speed_v = curtain_v_speed.value
		t.curtain_reverse_v = curtain_v_reverse.button_pressed
	else:
		t.erase("curtain_v")
		t.erase("curtain_speed_v")
		t.erase("curtain_reverse_v")


func _on_curtain_h_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	t.curtain_h = button_pressed
	restore_curtain_h()


func _on_curtain_v_checkbox_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	t.curtain_v = button_pressed
	restore_curtain_v()


func _on_curtain_h_reverse_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["curtain_h"]):
		t.curtain_reverse_h = button_pressed


func _on_curtain_v_reverse_toggled(button_pressed):
	if !_data_ready:
		return
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["curtain_v"]):
		t.curtain_reverse_v = button_pressed


func _on_curtain_h_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["curtain_h"]):
		t.curtain_speed_h = value


func _on_curtain_v_speed_value_changed(value):
	var t: Dictionary = src.transition
	if JSONHelper.gb(t, ["curtain_v"]):
		t.curtain_speed_v = value



