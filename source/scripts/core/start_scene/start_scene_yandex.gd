class_name StartSceneYandex
extends StartSceneWebGL

func _ready():
	_language_changer.set_language(YandexSDKAutoload.get_locale())

func _on_ready():
	._on_ready()
	
	_save_data_to_player_prefs(YandexSDKAutoload.get_cached_data_from_cloud())
	
#	YandexSDKAutoload.show_ad()

func _save_data_to_player_prefs(data):
	var save_data = YandexUtils.get_save_data(data)
	
	# remove unity prefs
	var prefs = [
		"feedbackDone",
		"isFirstSession",
		"language",
		"promptDone"
	]
	for pref in prefs:
		save_data.erase(pref)
	
	var highscore_pref = Highscore._HIGHSCORE_PREF
	if PlayerPrefsAutoload.has_pref(highscore_pref):
		var highscore = PlayerPrefsAutoload.get_pref(highscore_pref)
		if save_data.has(highscore_pref):
			highscore = max(highscore, save_data[highscore_pref])
			if highscore > save_data[highscore_pref]:
				save_data[highscore_pref] = highscore
				YandexSDKAutoload.save_data_to_cloud(save_data)
				YandexSDKAutoload.set_leaderboard_score(highscore)
		else:
			save_data[highscore_pref] = highscore
			YandexSDKAutoload.save_data_to_cloud(save_data)
			YandexSDKAutoload.set_leaderboard_score(highscore)
	else:
		if save_data.has(highscore_pref):
			var highscore = save_data[highscore_pref]
			PlayerPrefsAutoload.set_pref(highscore_pref, highscore)
			YandexSDKAutoload.save_data_to_cloud(save_data)
			YandexSDKAutoload.set_leaderboard_score(highscore)
	
	PlayerPrefsAutoload._settings.merge(save_data, true)
	save_progress_to_disk()
