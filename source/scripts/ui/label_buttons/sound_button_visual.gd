class_name SoundButtonVisual
extends LabelButtonVisual

export(NodePath) var _sounds_path
export(Texture) var _sound_on_texture
export(Texture) var _sound_off_texture

onready var _animation_player = $AnimationPlayer
onready var _sounds = get_node(_sounds_path)

func _ready():
	_sounds.connect("sound_muted", self, "_on_sound_muted")
	connect("button_pressed", self, "_toggle_sound")
	.connect("button_pressed", _animation_player, "play", ["animation_ui_scale_in_out"])
	_on_sound_muted(_sounds.is_muted())

func _toggle_sound():
	_sounds.mute(!_sounds.is_muted())

func _on_sound_muted(is_muted):
	if is_muted:
		_label_button.text = "KEY_SOUND_OFF"
		_button.icon = _sound_off_texture
	else:
		_label_button.text = "KEY_SOUND_ON"
		_button.icon = _sound_on_texture
