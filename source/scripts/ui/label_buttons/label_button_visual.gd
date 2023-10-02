class_name LabelButtonVisual
extends Node

signal button_pressed

onready var _label_button = $Label
onready var _button = $Button

func _ready():
	_button.connect("pressed", self, "_emit_button_pressed")
	_label_button.connect("pressed", self, "_emit_button_pressed")

func _emit_button_pressed():
	emit_signal("button_pressed")
