class_name ThemeButtonVisual
extends LabelButtonVisual

export(NodePath) var _settings_path
export(Texture) var _light_mode_texture
export(Texture) var _dark_mode_texture

var _is_toggled : bool = false

onready var _animation_player = $AnimationPlayer
onready var _settings = .get_node(_settings_path)
onready var _theme_changer = _settings._theme_changer

func _ready():
	.connect("button_pressed", self, "_toggle")
	.connect("button_pressed", _animation_player, "play", ["animation_ui_scale_in_out"])
	_theme_changer.connect("theme_changed", self, "_on_theme_changed")

func _toggle():
	if _is_toggled:
		_theme_changer.change_theme(ThemeChanger.Themes.LIGHT_THEME)
	else:
		_theme_changer.change_theme(ThemeChanger.Themes.DARK_THEME)

func _on_theme_changed(theme):
	_is_toggled = theme == ThemeChanger.Themes.DARK_THEME
	self._label_button.text = "KEY_THEME_DARK" if _is_toggled else "KEY_THEME_LIGHT"
	self._button.icon = _dark_mode_texture if _is_toggled else _light_mode_texture
