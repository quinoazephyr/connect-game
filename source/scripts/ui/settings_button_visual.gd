class_name SettingsButtonVisual
extends Node

signal button_pressed

export(NodePath) var _settings_label_button_path

onready var _settings_label_button = get_node(_settings_label_button_path)
onready var _settings_button = $SettingsButton
onready var _animation_player = $AnimationPlayer

func _ready():
	_settings_button.connect("pressed", self, "_emit_button_pressed")
	_settings_label_button.connect("pressed", self, "_emit_button_pressed")

func play_animation(is_clockwise_rotation : bool):
	var anim_str = "settings_button_rotation"
	if is_clockwise_rotation:
		_animation_player.play(anim_str)
	else:
		_animation_player.play_backwards(anim_str)

func _emit_button_pressed():
	emit_signal("button_pressed")
