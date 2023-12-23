class_name SetDataSafeStorageEmptyYandexButton
extends Node

func _ready():
	connect("pressed", self, "_send_set_data_empty")

func _send_set_data_empty():
	YandexSDKAutoload.save_data_to_safe_storage({})
