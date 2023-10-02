class_name ThemeChanger
extends Node

signal theme_changed(theme)

enum Themes {
	LIGHT_THEME,
	DARK_THEME
}

export(Array) var _themes
export(Array) var _accent_labels_paths
export(Array) var _labels_paths
export(Array) var _backgrounds_paths

var _accent_labels : Array
var _labels : Array
var _backgrounds : Array
var _current_theme : int

func _ready():
	for path in _accent_labels_paths:
		_accent_labels.append(get_node(path))
	for path in _labels_paths:
		_labels.append(get_node(path))
	for path in _backgrounds_paths:
		_backgrounds.append(get_node(path))

func change_theme(theme : int):
	_current_theme = theme
	_update_elements(_current_theme)
	emit_signal("theme_changed", _current_theme)

func _update_elements(theme : int):
	var theme_colors = _themes[theme]
	var tween_duration = 0.2
	var tween = get_tree().create_tween()
	for elem in _backgrounds:
		var elem_color = elem.self_modulate
		var new_color = theme_colors.background_color
		tween.parallel().tween_property(elem, "self_modulate", \
				Color(new_color.r, new_color.g, new_color.b, elem_color.a), \
				tween_duration)
	for elem in _accent_labels:
		var elem_color = elem.self_modulate
		var new_color = theme_colors.label_accent_color
		tween.parallel().tween_property(elem, "self_modulate", \
				Color(new_color.r, new_color.g, new_color.b, elem_color.a), \
				tween_duration)
	for elem in _labels:
		var elem_color = elem.self_modulate
		var new_color = theme_colors.label_color
		tween.parallel().tween_property(elem, "self_modulate", \
				Color(new_color.r, new_color.g, new_color.b, elem_color.a), \
				tween_duration)
