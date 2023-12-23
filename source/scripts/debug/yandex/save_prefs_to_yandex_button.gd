class_name SavePlayerPrefsToYandexButton
extends Button

func _ready():
	connect("pressed", self, "save_prefs_to_yandex")

func save_prefs_to_yandex():
	YandexSDKAutoload\
			.save_data({"saves" : [JSON.print(PlayerPrefsAutoload._settings)]})
