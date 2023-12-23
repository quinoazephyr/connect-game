class_name SaveDataToYandexNode
extends Node

onready var _text_edit = $TextEdit
onready var _button = $Button

func _ready():
	_button.connect("pressed", self, "save_data_from_text_edit")

func save_data_from_text_edit():
	print(_text_edit.text)
	var parse_res = JSON.parse(_text_edit.text)
	if parse_res.result.get_error() == OK:
		YandexSDKAutoload.save_data(parse_res.result)
