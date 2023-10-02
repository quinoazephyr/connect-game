class_name GameYandex
extends Game

var _yandex_wrapper : YandexSDKWrapper

func initialize(yandex_wrapper : YandexSDKWrapper):
	_yandex_wrapper = yandex_wrapper
	
	_popup_end_game.call_deferred("set_watch_ad_button_callback", \
			_yandex_wrapper, "show_ad_rewarded")
	_popup_end_game.call_deferred("set_watch_button_enabled", true)
	
	_yandex_wrapper.connect("rewarded_ad_success", self, \
			"_on_rewarded_ad_success", [], CONNECT_DEFERRED)
	
	connect("tree_exiting",\
			_yandex_wrapper,\
			"disconnect",\
			["rewarded_ad_success", self, "_on_rewarded_ad_success"])
	
	call_deferred("_load_highscore_from_cloud")

func _on_new_game_pressed():
	get_tree().create_timer(2.0).connect("timeout", \
			_popup_end_game, "set_watch_button_enabled", [true])
	._on_new_game_pressed()

func _on_rewarded_ad_success():
	_moves.set_moves(10)
	_popup_end_game.set_watch_button_enabled(false)
	_popup_end_game.hide_popup()
	
	_game_input.enable_input(true)

func _load_highscore_from_cloud():
	var highscore_from_browser = _highscore.get_highscore()
	var highscore_from_yandex = highscore_from_browser
	if _yandex_wrapper._loaded_data && \
			_yandex_wrapper._loaded_data.has("highscore"):
		var highscore_from_cloud = _yandex_wrapper._loaded_data.has("highscore")
		highscore_from_yandex = highscore_from_cloud
		_highscore.evaluate_and_set_highscore(highscore_from_cloud)
	if _yandex_wrapper._loaded_data_from_safe_storage && \
			_yandex_wrapper._loaded_data_from_safe_storage.has("highscore"):
		var highscore_from_safe_storage = \
				_yandex_wrapper._loaded_data_from_safe_storage.has("highscore")
		highscore_from_yandex = highscore_from_safe_storage
		_highscore.evaluate_and_set_highscore(highscore_from_safe_storage)
	if highscore_from_browser != highscore_from_yandex:
		_highscore.save_me(_player_prefs)
		_yandex_wrapper.save_data({ "highscore" : highscore_from_yandex })
