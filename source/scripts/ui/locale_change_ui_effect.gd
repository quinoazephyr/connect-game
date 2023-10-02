class_name LocaleChangeUIEffect
extends Node


export(Array) var _ui_elements_paths
export(NodePath) var _locale_changer_path

var _ui_elements : Array

onready var _locale_changer = get_node(_locale_changer_path)

func _ready():
	for path in _ui_elements_paths:
		var elem = get_node(path)
		_ui_elements.append(elem)
	_locale_changer.connect("locale_changed", self, "_bounce_elements")
	var yandex_sdk_wrapper = get_tree().root.get_node("/root/YandexSdkWrapper")
	yandex_sdk_wrapper.connect("locale_loaded", _locale_changer, "set_locale")
	connect("tree_exiting", \
			yandex_sdk_wrapper, \
			"disconnect", \
			["locale_loaded", _locale_changer, "set_locale"])

func _bounce_elements(locale_name):
	var tween = get_tree().create_tween()
	for elem in _ui_elements:
		tween.parallel().tween_property(elem, "rect_scale", Vector2.ONE * 1.5, 0.15)\
				.from(Vector2.ONE)
	tween.tween_property(self, "name", name, 0.0)
	for elem in _ui_elements:
		tween.parallel().tween_property(elem, "rect_scale", Vector2.ONE, 0.15)
