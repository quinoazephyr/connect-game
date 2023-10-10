class_name SceneBase
extends Node

onready var _audio = $Audio
onready var _theme_nodes_collection = $ThemeNodesCollection
onready var _buttons = []

func _ready():
	connect("ready", _audio, "connect", ["muted", self, "_on_audio_muted"])
	connect("ready", _audio, "mute", [false]) # TEMP !!!!!!!!!!!!!!!

func _enter_tree():
	SceneChangerAutoload.call_deferred("connect", \
			"scene_changing", self, "_copy_audio_between_scenes")
	SceneChangerAutoload.call_deferred("connect", \
			"scene_changing", self, "_copy_theme_between_scenes")

func _exit_tree():
	SceneChangerAutoload.disconnect("scene_changing", self, \
			"_copy_audio_between_scenes")
	SceneChangerAutoload.disconnect("scene_changing", self, \
			"_copy_theme_between_scenes")

func _set_initial_theme():
	ThemeChangerAutoload.change_theme_by_name(_get_initial_theme_name())

func _get_initial_theme_name():
	return "Light"

func _copy_audio_between_scenes(current_scene_root, next_scene_root):
	next_scene_root._audio.copy_from(current_scene_root._audio)

func _copy_theme_between_scenes(current_scene_root, next_scene_root):
	ThemeChangerAutoload.change_theme(ThemeChangerAutoload.last_valid_theme)

func _on_audio_muted(is_muted):
	if is_muted:
		_disconnect_sounds_from_buttons()
	else:
		_connect_sounds_to_ui_buttons()

func _connect_sounds_to_ui_buttons():
	for button in _buttons:
		button.connect("pressed", _audio, "play_sound", ["ui_button_press"])

func _disconnect_sounds_from_buttons():
	for button in _buttons:
		button.disconnect("pressed", _audio, "play_sound")
