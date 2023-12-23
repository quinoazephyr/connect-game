class_name ColorblindButtonVisual
extends AnimatedLabelButton

export(NodePath) var _colorblind_mode_path

onready var _colorblind_mode = get_node(_colorblind_mode_path)

func _ready():
	.connect("pressed", self, "_toggle")
	_colorblind_mode.connect("colorblind_changed", self, \
			"_on_colorblind_mode_changed")

func _toggle():
	_colorblind_mode.activate_mode(!_colorblind_mode.is_active)

func _on_colorblind_mode_changed(is_enabled : bool):
	_label_button.text = "KEY_COLORBLIND_ON" if is_enabled else \
			"KEY_COLORBLIND_OFF"
