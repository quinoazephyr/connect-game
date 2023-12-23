class_name ColorblindMode
extends Saveable

signal colorblind_changed(is_enabled)

const _IS_COLORBLIND_PREF = "is_colorblind"

var is_active setget, _is_mode_active

var _is_active : bool = false

func activate_mode(is_enabled : bool):
	_is_active = is_enabled
	emit_signal("colorblind_changed", is_enabled)

func _is_mode_active():
	return _is_active

func save_me(player_prefs : PlayerPrefs):
	player_prefs.set_pref(_IS_COLORBLIND_PREF, _is_mode_active())

func load_me(player_prefs : PlayerPrefs):
	if player_prefs.has_pref(_IS_COLORBLIND_PREF):
		activate_mode(player_prefs.get_pref(_IS_COLORBLIND_PREF))
	else:
		activate_mode(false)
