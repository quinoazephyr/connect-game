class_name ThemeChanger
extends Node

signal theme_changed(theme_colors)

export(Array) var _themes

var last_valid_theme setget, get_last_valid_theme

var _last_valid_theme : ThemeColors

func change_theme(theme : ThemeColors):
	if theme:
		_last_valid_theme = theme
		emit_signal("theme_changed", theme)

func change_theme_by_name(theme_name : String):
	var theme = _find_theme(theme_name)
	if theme:
		_last_valid_theme = theme
		emit_signal("theme_changed", theme)

func get_last_valid_theme():
	return _last_valid_theme

func _find_theme(theme_name : String):
	for theme in _themes:
		if theme.theme_name == theme_name:
			return theme
	return null
