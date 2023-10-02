class_name Settings
extends Node

export(NodePath) var _game_input_path
export(NodePath) var _theme_changer_path
export(NodePath) var _colorblind_mode_path
export(NodePath) var _sound_path
export(NodePath) var _dots_path
export(NodePath) var _score_path

var is_initial_run : bool = true

onready var _game_input = get_node(_game_input_path)
onready var _theme_changer = get_node(_theme_changer_path)
onready var _dots = get_node(_dots_path)
onready var _colorblind_mode = get_node(_colorblind_mode_path)
onready var _sound = get_node(_sound_path)
onready var _score = get_node(_score_path)

func _ready():
	_dots.connect("ready", self, "call_deferred", ["_load_dots_initial"])
#	_theme_changer.connect("ready", self, "call_deferred", ["_load_theme_initial"])
	_colorblind_mode.connect("ready", self, "call_deferred", ["_load_colorblind_mode_initial"])
	_sound.connect("ready", self, "call_deferred", ["_load_sound_initial"])

func _load_dots_initial():
	_dots.current_colors_count = _score.get_color_count(0)
	_dots.generate_new()

func _load_theme_initial():
	if is_initial_run:
		if OS.has_feature("HTML5"):
			var window = JavaScript.get_interface("window")
			if window.isDarkMode():
				_theme_changer.change_theme(ThemeChanger.Themes.DARK_THEME)
			else:
				_theme_changer.change_theme(ThemeChanger.Themes.LIGHT_THEME)
		else:
			_theme_changer.change_theme(ThemeChanger.Themes.LIGHT_THEME)

func _load_colorblind_mode_initial():
	if is_initial_run:
		_colorblind_mode.activate_mode(false)

func _load_sound_initial():
	_sound.load_sounds()
	if is_initial_run:
		_sound.load_sounds_to_js()
		_sound.mute(false)
