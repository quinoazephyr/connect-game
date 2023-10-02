class_name PopupWithBackground
extends Node

onready var _popup = $PopupDialog
onready var _background = $ColorRect

func _ready():
	_popup.connect("about_to_show", _background, "set_visible", [true])
	_popup.connect("popup_hide", _background, "set_visible", [false], \
			CONNECT_DEFERRED)
	
	_background.connect("resized", self, "_center_popup")

func show_popup():
	show_popup_delayed(0.0)

func show_popup_delayed(delay : float):
	_popup.popup_centered()
	
	var centered_rect_position = _popup.rect_position
	var out_of_screen_rect_position = Vector2(centered_rect_position.x, \
			-_popup.rect_size.y)
	_popup.rect_position = out_of_screen_rect_position
	
	var initial_color = _background.color
	var clear_color = Color(initial_color.r, initial_color.g, initial_color.b, \
			0.0)
	_background.color = clear_color
	
	var tween_duration = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(_background, "color", initial_color, tween_duration)\
			.from(clear_color).set_delay(delay)
	tween.parallel()\
			.tween_property(_popup, "rect_position", \
			centered_rect_position, tween_duration) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)\
			.set_delay(delay)

func hide_popup():
	var centered_rect_position = _popup.rect_position
	var out_of_screen_rect_position = Vector2(centered_rect_position.x, \
			-_popup.rect_size.y)
	
	var initial_color = _background.color
	var clear_color = Color(initial_color.r, initial_color.g, initial_color.b, \
			0.0)
	
	var tween_duration = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(_background, "color", clear_color, tween_duration)\
			.from(initial_color)
	tween.parallel().tween_property(_popup, "rect_position", \
			out_of_screen_rect_position, tween_duration) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(_popup, "set_visible", [false])
	tween.tween_callback(_background, "set_frame_color", [initial_color])

func _center_popup():
	var window_size = _background.rect_size
	var popup_size = _popup.rect_size
	_popup.rect_position = (window_size - popup_size) / 2.0
