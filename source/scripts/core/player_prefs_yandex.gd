class_name PlayerPrefsYandex
extends PlayerPrefs

func _ready():
	YandexSDKAutoload.connect("data_loaded_from_safe_storage", \
			self, "_save_loaded_data")

func save_data(path = _FILENAME):
	YandexSDKAutoload.save_data_to_safe_storage(_settings)

func load_data(path = _FILENAME):
	_settings = YandexSDKAutoload.get_cached_data_from_safe_storage()

func remove_pref(property):
	_settings.erase(property)
	YandexSDKAutoload.remove_data_from_safe_storage([property])

func remove_prefs(properties):
	for pref in properties:
		_settings.erase(pref)
	YandexSDKAutoload.remove_data_from_safe_storage(properties)

func clear_all(path = _FILENAME):
	_settings.clear()
	YandexSDKAutoload.clear_safe_storage()

func _save_loaded_data(data):
	_settings = data
