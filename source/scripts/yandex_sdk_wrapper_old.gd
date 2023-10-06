class_name YandexSDKWrapperOld
extends Node

signal rewarded_ad_success
signal rewarded_ad_error
signal data_loaded_from_cloud(data)
signal data_loaded_from_safe_storage(data)
signal locale_loaded(locale_name)

const _DATA_KEYS = {
	"2.0" : [
		"isFirstSession",
		"gameVersion",
		"highscore"
	]
}
const _GAME_VERSION = "2.0"

var _locale_name = "en"
var _loaded_data
var _loaded_data_from_safe_storage

onready var _yandex_sdk = get_node("/root/YandexSDK")

func _ready():
	call_deferred("initialize", _yandex_sdk)
	_yandex_sdk.connect("game_initialized", self, "show_ad")

func initialize(yandex_sdk : YandexSDKWrapper):
	_yandex_sdk = yandex_sdk
	
	_yandex_sdk.init_game()
	_yandex_sdk.init_player()
	_yandex_sdk.init_leaderboards()
	
	_yandex_sdk.connect("data_loaded", self, "_emit_data_loaded_from_cloud")
	_yandex_sdk.connect("data_loaded_from_safe_storage", self, \
			"_emit_data_loaded_from_safe_storage")
	_yandex_sdk.connect("rewarded_ad", self, "_emit_rewarded_ad_res")
	_yandex_sdk.connect("locale_answered", self, "_set_locale")
	
	_yandex_sdk.ask_locale()
	
	connect("data_loaded_from_cloud", self, "_process_loaded_data")
	connect("data_loaded_from_safe_storage", self, \
			"_process_loaded_data_from_safe_storage")
	load_data(_DATA_KEYS[_GAME_VERSION])

func load_data(data_keys : Array):
	_yandex_sdk.load_data(data_keys)
	_yandex_sdk.load_data_from_safe_storage(data_keys)

func save_data(data : Dictionary):
	_yandex_sdk.save_data_to_safe_storage(data)
	_yandex_sdk.save_data(data)

func show_ad():
	_yandex_sdk.show_ad()

func show_ad_rewarded():
	_yandex_sdk.show_rewarded_ad()

func set_leaderboard_score(score : int):
	_yandex_sdk.set_leaderboard_score(score)

func get_locale_name():
	return _locale_name

func _emit_data_loaded_from_cloud(data):
	var json
	if data.has("saves"):
		json = data["saves"][0]
	else:
		json = data
	var json_parsed = JSON.parse(json)
	emit_signal("data_loaded_from_cloud", json_parsed.result)

func _emit_data_loaded_from_safe_storage(data):
	var json_parsed = JSON.parse(data)
	emit_signal("data_loaded_from_safe_storage", json_parsed.result)

func _emit_rewarded_ad_res(result):
	if result[0] == "rewarded":
		emit_signal("rewarded_ad_success")
	else:
		emit_signal("rewarded_ad_error")

func _set_locale(locale_name):
	_locale_name = locale_name
	emit_signal("locale_loaded", _locale_name)

func _process_loaded_data(data):
	_loaded_data = data

func _process_loaded_data_from_safe_storage(data):
	_loaded_data_from_safe_storage = data
