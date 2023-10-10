class_name ThemeButtonVisual
extends AnimatedLabelButton

export(Texture) var _light_mode_texture
export(Texture) var _dark_mode_texture

func _enter_tree():
	ThemeChangerAutoload.connect("theme_changed", self, "_update_visuals")
	
	connect("pressed", self, "_toggle")
#	connect("pressed", _animation_player, "play", ["animation_ui_scale_in_out"])

func _exit_tree():
	ThemeChangerAutoload.disconnect("theme_changed", self, "_update_visuals")

func _toggle():
	if ThemeChangerAutoload.last_valid_theme.theme_name == "Dark":
		ThemeChangerAutoload.change_theme_by_name("Light")
	else:
		ThemeChangerAutoload.change_theme_by_name("Dark")

func _update_visuals(theme):
	var is_toggled = theme.theme_name == "Dark"
	_label_button.text = "KEY_THEME_DARK" if is_toggled else "KEY_THEME_LIGHT"
	_button.icon = _dark_mode_texture if is_toggled else _light_mode_texture
