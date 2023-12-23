class_name ThemeChanger
extends Saveable

signal theme_changed(theme_colors)

const _THEME_PREF = "theme"

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
	elif !_last_valid_theme:
		theme = _themes[0]
		_last_valid_theme = theme
	emit_signal("theme_changed", _last_valid_theme)

func save_me(player_prefs : PlayerPrefs):
	player_prefs.set_pref(_THEME_PREF, _last_valid_theme.theme_name)

func load_me(player_prefs : PlayerPrefs):
	if player_prefs.has_pref(_THEME_PREF):
		change_theme_by_name(player_prefs.get_pref(_THEME_PREF))

func get_last_valid_theme():
	return _last_valid_theme

func _find_theme(theme_name : String):
	for theme in _themes:
		if theme.theme_name == theme_name:
			return theme
	return null
