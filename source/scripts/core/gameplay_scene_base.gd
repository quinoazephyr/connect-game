class_name GameplaySceneBase
extends SceneBase

onready var _game_input = $GameInput
onready var _colorblind_mode = $ColorblindMode

func _ready():
	_saveables.append_array([
		_colorblind_mode
	])
	
	_colorblind_mode\
			.connect("colorblind_changed", self, "_set_colorblind_mode")

func _connect_game_input():
	pass

func _disconnect_game_input():
	pass

func _set_colorblind_mode(is_enabled : bool):
	pass

func _connect_audio():
	pass

func _disconnect_audio():
	pass

func _on_audio_muted(is_muted):
	._on_audio_muted(is_muted)
	
	if is_muted:
		_disconnect_audio()
	else:
		_connect_audio()
