class_name ThemeColors
extends Resource

export(String) var _theme_name
export(Color) var _label_accent_color
export(Color) var _label_color
export(Color) var _background_color

var theme_name setget , get_theme_name
var label_accent_color setget , get_label_accent_color
var label_color setget , get_label_color
var background_color setget , get_background_color

func get_theme_name():
	return _theme_name

func get_label_accent_color():
	return _label_accent_color

func get_label_color():
	return _label_color

func get_background_color():
	return _background_color
