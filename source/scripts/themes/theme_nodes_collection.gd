class_name ThemeNodesCollection
extends Node

export(Array) var _accent_labels_paths
export(Array) var _labels_paths
export(Array) var _backgrounds_paths

var _accent_labels : Array
var _labels : Array
var _backgrounds : Array
var _tween

func _ready():
	for path in _accent_labels_paths:
		_accent_labels.append(get_node(path))
	for path in _labels_paths:
		_labels.append(get_node(path))
	for path in _backgrounds_paths:
		_backgrounds.append(get_node(path))
	
	ThemeChangerAutoload.connect("theme_changed", self, "update_elements")

func update_elements(theme_colors):
	var tween_duration = 0.2
	if _tween:
		_tween.kill()
	_tween = create_tween()
	for elem in _backgrounds:
		var elem_color = elem.self_modulate
		var new_color = theme_colors.background_color
		_tween.parallel().tween_property(elem, "self_modulate", \
				Color(new_color.r, new_color.g, new_color.b, elem_color.a), \
				tween_duration)
	for elem in _accent_labels:
		var elem_color = elem.self_modulate
		var new_color = theme_colors.label_accent_color
		_tween.parallel().tween_property(elem, "self_modulate", \
				Color(new_color.r, new_color.g, new_color.b, elem_color.a), \
				tween_duration)
	for elem in _labels:
		var elem_color = elem.self_modulate
		var new_color = theme_colors.label_color
		_tween.parallel().tween_property(elem, "self_modulate", \
				Color(new_color.r, new_color.g, new_color.b, elem_color.a), \
				tween_duration)
