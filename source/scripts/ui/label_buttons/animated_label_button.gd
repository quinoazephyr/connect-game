class_name AnimatedLabelButton
extends Control

signal pressed

onready var _label_button = $Label
onready var _button = $Button
onready var _animation_player = $AnimationPlayer

func _ready():
	_button.connect("pressed", self, "_emit_button_pressed")
	_label_button.connect("pressed", self, "_emit_button_pressed")

func _emit_button_pressed():
	emit_signal("pressed")
