class_name SceneBase
extends Node

onready var _audio = $Audio
onready var _theme_nodes_collection = $ThemeNodesCollection
onready var _buttons = []
onready var _saveables = []

func _ready():
	_saveables = [
		_audio,
		ThemeChangerAutoload
	]
	
	connect("ready", self, "_on_ready")

func _enter_tree():
	SceneChangerAutoload.call_deferred("connect", \
			"scene_changing", self, "_copy_audio_between_scenes")

func _exit_tree():
	SceneChangerAutoload.disconnect("scene_changing", self, \
			"_copy_audio_between_scenes")

func load_progress():
	for saveable in _saveables:
		saveable.load_me(PlayerPrefsAutoload)

func save_progress():
	for saveable in _saveables:
		saveable.save_me(PlayerPrefsAutoload)

func load_progress_from_disk():
	PlayerPrefsAutoload.load_data()
	load_progress()

func save_progress_to_disk():
	save_progress()
	PlayerPrefsAutoload.save_data()

func _on_ready():
	_audio.connect("muted", self, "_on_audio_muted")

func _set_initial_theme():
	ThemeChangerAutoload.change_theme_by_name(_get_initial_theme_name())

func _get_initial_theme_name():
	return "Light"

func _copy_audio_between_scenes(current_scene_root, next_scene_root):
	next_scene_root._audio.copy_from(current_scene_root._audio)

func _on_audio_muted(is_muted):
	if is_muted:
		_disconnect_sounds_from_buttons()
	else:
		_connect_sounds_to_buttons()

func _connect_sounds_to_buttons():
	for button in _buttons:
		button.connect("pressed", _audio, "play_sound", ["ui_button_press"])

func _disconnect_sounds_from_buttons():
	for button in _buttons:
		if button.is_connected("pressed", _audio, "play_sound"):
			button.disconnect("pressed", _audio, "play_sound")
