class_name LanguageChanger
extends Node

signal language_changed(locale_name)

export(Array) var _locales = [ "en" ]

onready var _current_locale_idx = 0
onready var _current_locale = _locales[_current_locale_idx]

func set_system_language():
	set_language(TranslationServer.get_locale())

func set_language(locale : String):
	_current_locale_idx = clamp(_locales.find(locale), 0, _locales.size() - 1)
	_current_locale = _locales[_current_locale_idx]
	TranslationServer.set_locale(_current_locale)
	emit_signal("language_changed", _current_locale)

func set_language_by_index(idx : int):
	if idx < 0 || idx > _locales.size() - 1:
		return
	set_language(_locales[idx])

func set_next_language():
	var idx = _current_locale_idx + 1
	if idx == _locales.size():
		idx = 0
	set_language(_locales[idx])

func set_previous_language():
	var idx = _current_locale_idx - 1
	if idx == 0:
		idx = _locales.size() - 1
	set_language(_locales[idx])

