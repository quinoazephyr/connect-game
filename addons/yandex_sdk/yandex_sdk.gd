class_name YandexSDK
extends Node

signal rewarded_ad(result)
signal ad(result)
signal game_initialized()
signal player_initialized()
signal leaderboards_initialized()
signal data_loaded(data)
signal data_loaded_from_safe_storage(data)
signal stats_loaded(stats)
signal locale_answered(locale_name)

const _FEATURE_NAME = "yandex"
const _LEADERBOARD_NAME = "LeaderboardHighscore"

var game_inialized : bool = false
var player_inialized : bool = false
var leaderboards_inialized : bool = false

var callback_game_initialized = JavaScript.create_callback(self, '_game_initialized')
var callback_player_initialized = JavaScript.create_callback(self, '_player_initialized')
var callback_leaderboards_initialized = JavaScript.create_callback(self, '_leaderboards_initialized')

var callback_rewarded_ad = JavaScript.create_callback(self, '_rewarded_ad')
var callback_ad = JavaScript.create_callback(self, '_ad')

var callback_data_loaded = JavaScript.create_callback(self, '_data_loaded')
var callback_data_loaded_from_safe_storage = JavaScript.create_callback(self, '_data_loaded_from_safe_storage')
var callback_stats_loaded = JavaScript.create_callback(self, '_stats_loaded')

var callback_locale_answered = JavaScript.create_callback(self, '_locale_answered')

onready var window = JavaScript.get_interface("window")

static func is_yandex():
	return OS.has_feature(_FEATURE_NAME)

func init_game():
	if is_yandex():
		if not game_inialized :
			var options = JavaScript.create_object("Object")
			window.InitGame(options, callback_game_initialized)


func show_ad():
	if is_yandex():
		if not game_inialized :
			yield(self, "game_initialized")
		window.ShowAd(callback_ad)


func show_rewarded_ad():
	if is_yandex():
		if not game_inialized :
			yield(self, "game_initialized")
		window.ShowAdRewardedVideo(callback_rewarded_ad)


func init_player():
	if is_yandex():
		if not game_inialized:
			yield(self, "game_initialized")
		window.InitPlayer(false, callback_player_initialized)

func init_leaderboards():
	if is_yandex():
		if not player_inialized:
			yield(self, "player_initialized")
		window.InitLeaderboards(callback_leaderboards_initialized)

func save_data(data: Dictionary, flush: bool = false):
	if is_yandex():
		if not player_inialized:
			yield(self, "player_initialized")
		var saves = JavaScript.create_object("Object")
		for i in data.keys():
			saves[i] = data[i]
		window.SaveData(saves, flush)

func save_data_to_safe_storage(data : Dictionary):
	if is_yandex():
		if not player_inialized:
			yield(self, "player_initialized")
		var saves = JavaScript.create_object("Object")
		for key in data.keys():
			saves[key] = data[key]
		window.SaveDataToSafeStorage(saves)

func save_stats(stats: Dictionary):
	if is_yandex():
		if not player_inialized:
			yield(self, "player_initialized")
		var saves = JavaScript.create_object("Object")
		for i in stats.keys():
			saves[i] = stats[i]
		window.SaveStats(saves)


func load_data(data : Array):
	if is_yandex():
		if not player_inialized:
			yield(self, "player_initialized")
		var saves = JavaScript.create_object("Array", data.size())
		for i in data.size():
			saves[i] = data[i]
		window.LoadData(saves, callback_data_loaded)

func load_data_from_safe_storage(data : Array):
	if is_yandex():
		if not player_inialized:
			yield(self, "player_initialized")
		var saves = JavaScript.create_object("Array", data.size())
		for i in data.size():
			saves[i] = data[i]
		window.LoadDataFromSafeStorage(saves, callback_data_loaded_from_safe_storage)


func load_stats(keys: Array):
	if is_yandex():
		if not player_inialized:
			yield(self, "player_initialized")
		var saves = JavaScript.create_object("Array", keys.size())
		for i in range(keys.size()):
			saves[i] = keys[i]
		window.LoadStats(saves, callback_stats_loaded)

func set_leaderboard_score(score : int, leaderboard_name : String = _LEADERBOARD_NAME):
	if is_yandex():
		if not leaderboards_inialized:
			yield(self, "leaderboards_initialized")
		var lb_name = JavaScript.create_object("String")
		lb_name = leaderboard_name
		var user_score = JavaScript.create_object("Number")
		user_score = score
		window.SetLeaderboardScore(lb_name, user_score)

func ask_locale():
	if is_yandex():
		if not game_inialized :
			yield(self, "game_initialized")
		window.GetLocale(callback_locale_answered)

func _locale_answered(locale_name):
	emit_signal("locale_answered", locale_name[0])

func _rewarded_ad(args):
	print("rewarded ad res: ", args[0])
	emit_signal("rewarded_ad", args)


func _ad(args):
	print("ad res: ", args[0])
	emit_signal("ad", args[0])


func _data_loaded(args):
	if args[0] == 'loaded':
		var result := {}
		var keys = JavaScript.get_interface("Object").keys(args[1])
		var values = JavaScript.get_interface("Object").values(args[1])
		for i in range(keys.length):
			result[keys[i]] = values[i]
		emit_signal("data_loaded", result)

func _data_loaded_from_safe_storage(args):
	pass

func _stats_loaded(args):
	if args[0] == 'loaded':
		var result := {}
		var keys = JavaScript.get_interface("Object").keys(args[1])
		var values = JavaScript.get_interface("Object").values(args[1])
		for i in range(keys.length):
			result[keys[i]] = values[i]
		emit_signal("stats_loaded", result)


func _game_initialized(args):
	game_inialized = true
	emit_signal('game_initialized')


func _player_initialized(args):
	player_inialized = true
	emit_signal('player_initialized')

func _leaderboards_initialized(args):
	leaderboards_inialized = true
	emit_signal("leaderboards_initialized")
