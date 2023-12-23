class_name GameSceneYandex
extends GameSceneBase

signal rewarded_ad_success
signal rewarded_ad_error

func _on_ready():
	YandexSDKAutoload.show_ad()
	YandexSDKAutoload.connect("rewarded_ad", self, "_emit_rewarded_ad_res")
	connect("rewarded_ad_success", _moves, "add_moves", [10])
	connect("rewarded_ad_success", _popup_endgame, "hide_popup")
	connect("rewarded_ad_success", _popup_endgame, \
			"set_watch_button_enabled", [false])
	connect("rewarded_ad_success", self, \
			"_save_gameplay_to_disk", [], CONNECT_DEFERRED)
	connect("rewarded_ad_success", self, \
			"_save_more_moves_granted", [true])
	
	._on_ready()

func _restart_game():
	_try_save_highscore_to_cloud()
	._restart_game()

func _show_tutorial():
	_try_save_highscore_to_cloud()
	._show_tutorial()

func _on_finish_game():
	_try_save_highscore_to_cloud()
	._on_finish_game()

func _try_save_highscore_to_cloud():
	if _score.get_score() > _highscore.get_highscore():
		PlayerPrefsAutoload.set_pref(_highscore._HIGHSCORE_PREF, _score.get_score())
		var cached_data = YandexSDKAutoload.get_cached_data_from_cloud()
		var data = {
			_highscore._HIGHSCORE_PREF : _score.get_score()
		}
		cached_data.merge(data, true)
		YandexSDKAutoload.save_data_to_cloud(cached_data)
		YandexSDKAutoload.set_leaderboard_score(_score.get_score())

func _set_popup_endgame_watch_ad_callbacks():
	_popup_endgame.set_watch_ad_button_callback(YandexSDKAutoload, "show_rewarded_ad")

func _emit_rewarded_ad_res(result):
	if result[0] == "rewarded":
		emit_signal("rewarded_ad_success")
	else:
		emit_signal("rewarded_ad_error")
