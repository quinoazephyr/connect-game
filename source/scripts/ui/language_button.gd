class_name LanguageButton
extends Button

signal locale_changed(locale_name)

const _LOCALES = [
	"en",
	"ru"
]

var _current_locale_idx = 0

onready var _flag_icon = $TextureRect
onready var _label = $Label

func _ready():
	var idx = clamp(_LOCALES.find(TranslationServer.get_locale()), \
			0, _LOCALES.size() - 1)
	_set_locale(idx)
	connect("pressed", self, "_set_next_locale")

func set_locale(locale_name : String):
	var idx = clamp(_LOCALES.find(locale_name), \
			0, _LOCALES.size() - 1)
	_set_locale(idx)

func _set_next_locale():
	var idx = _current_locale_idx + 1
	if idx == _LOCALES.size():
		idx = 0
	_set_locale(idx)

func _set_locale(idx):
	_current_locale_idx = idx
	TranslationServer.set_locale(_LOCALES[_current_locale_idx])
	emit_signal("locale_changed", _LOCALES[_current_locale_idx])
