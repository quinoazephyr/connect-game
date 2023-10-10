class_name AudioLabelButton
extends AnimatedLabelButton

export(NodePath) var _audio_path
export(Texture) var _audio_unmuted_texture
export(Texture) var _audio_muted_texture

onready var _audio = get_node(_audio_path)

func _ready():
	_audio.connect("muted", self, "_update_visuals")
	_update_visuals(_audio.is_muted)
	
	connect("pressed", self, "_toggle_button")
#	.connect("pressed", _animation_player, "play", ["animation_ui_scale_in_out"])

func _toggle_button():
	_audio.mute(!_audio.is_muted)

func _update_visuals(is_muted):
	if is_muted:
		_label_button.text = "KEY_SOUND_OFF"
		_button.icon = _audio_muted_texture
	else:
		_label_button.text = "KEY_SOUND_ON"
		_button.icon = _audio_unmuted_texture
