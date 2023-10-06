class_name LocaleChangeUIEffect
extends Node

export(Array) var _ui_elements_paths
export(NodePath) var _language_changer_path

var _ui_elements : Array
var _tween

onready var _language_changer = get_node(_language_changer_path)

func _ready():
	for path in _ui_elements_paths:
		var elem = get_node(path)
		_ui_elements.append(elem)
	_language_changer.connect("language_changed", self, "bounce_elements")

func bounce_elements(locale_name):
	if _tween:
		_tween.kill()
	_tween = create_tween()
	for elem in _ui_elements:
		_tween.parallel().tween_property(elem, "rect_scale", Vector2.ONE * 1.5, 0.15)\
				.from(Vector2.ONE)
	_tween.tween_property(self, "name", name, 0.0)
	for elem in _ui_elements:
		_tween.parallel().tween_property(elem, "rect_scale", Vector2.ONE, 0.15)
