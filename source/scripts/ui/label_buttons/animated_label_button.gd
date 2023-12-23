class_name AnimatedLabelButton
extends Control

signal pressed

export(String) var _anim_pressed_name = ""

onready var _label_button = $Label
onready var _button = $Button
onready var _animation_player = $AnimationPlayer

func _ready():
	_button.connect("pressed", self, "_emit_button_pressed")
	_label_button.connect("pressed", self, "_emit_button_pressed")
	connect("pressed", self, "_play_anim_pressed")

func _emit_button_pressed():
	emit_signal("pressed")

func _play_anim_pressed():
	if _animation_player.has_animation(_anim_pressed_name):
		_animation_player.play(_anim_pressed_name)
