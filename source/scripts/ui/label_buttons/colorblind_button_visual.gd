class_name ColorblindButtonVisual
extends LabelButtonVisual

export(NodePath) var _settings_path

var _is_toggled : bool = false

onready var _animation_player = $AnimationPlayer
onready var _settings = .get_node(_settings_path)
onready var _colorblind_mode = _settings._colorblind_mode

func _ready():
	.connect("button_pressed", self, "_toggle")
	.connect("button_pressed", _animation_player, "play", ["animation_ui_wiggle"])
	_colorblind_mode.connect("colorblind_changed", self, "_on_colorblind_mode_changed")

func _toggle():
	_colorblind_mode.activate_mode(!_is_toggled)

func _on_colorblind_mode_changed(is_enabled : bool):
	_is_toggled = is_enabled
	self._label_button.text = "KEY_COLORBLIND_ON" if _is_toggled else \
			"KEY_COLORBLIND_OFF"
