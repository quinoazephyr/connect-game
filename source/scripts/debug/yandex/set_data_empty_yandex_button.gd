class_name SetDataEmptyYandexButton
extends Node

func _ready():
	connect("pressed", self, "_send_set_data_empty")

func _send_set_data_empty():
	YandexSDKAutoload.save_data({})
