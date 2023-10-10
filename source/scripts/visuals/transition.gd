class_name Transition
extends Node

signal transition_started
signal transition_hid_screen
signal transition_ended

export(float) var _transition_time = 0.5
export(float) var _transition_rect_show_time = 0.2

onready var _color_rect = $TransitionColorRect

func show_transition(delay = 0.0):
	var transition_time_half = _transition_time * 0.5
	hide_screen(delay)
	show_screen(delay + transition_time_half + _transition_rect_show_time)

func hide_screen(delay = 0.0):
	var solid_rect_color = Color(_color_rect.color.r, _color_rect.color.g, \
			_color_rect.color.b, 1.0)
	var clear_rect_color = Color(solid_rect_color.r, solid_rect_color.g, \
			solid_rect_color.b, 0.0)
	var transition_time_half = _transition_time * 0.5
	var tween = get_tree().create_tween()
	tween.tween_callback(self, "emit_signal", ["transition_started"]).set_delay(delay)
	tween.tween_callback(_color_rect, "set_visible", [true])
	tween.tween_callback(_color_rect, "set_frame_color", [clear_rect_color])
	tween.tween_property(_color_rect, "color", \
			solid_rect_color, transition_time_half)
	tween.tween_callback(self, "emit_signal", ["transition_hid_screen"])

func show_screen(delay = 0.0):
	var solid_rect_color = Color(_color_rect.color.r, _color_rect.color.g, \
			_color_rect.color.b, 1.0)
	var clear_rect_color = Color(solid_rect_color.r, solid_rect_color.g, \
			solid_rect_color.b, 0.0)
	var transition_time_half = _transition_time * 0.5
	var tween = get_tree().create_tween()
	tween.tween_callback(_color_rect, "set_visible", [true]).set_delay(delay)
	tween.tween_callback(_color_rect, "set_frame_color", [solid_rect_color])
	tween.tween_property(_color_rect, "color", \
			clear_rect_color, transition_time_half)
	tween.tween_callback(_color_rect, "set_visible", [false])
	tween.tween_callback(self, "emit_signal", ["transition_ended"])
