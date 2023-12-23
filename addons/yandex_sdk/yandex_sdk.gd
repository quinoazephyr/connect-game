class_name YandexSDK
extends Node

signal sdk_object_initialized
signal sdk_initialized
signal player_initialized
signal leaderboards_initialized
signal ad(result)
signal rewarded_ad(result)
signal data_loaded_from_cloud(data)
signal data_loaded_from_safe_storage(data)
signal stats_loaded(stats)

const _FEATURE_NAME = "yandex"
const _LEADERBOARD_NAME = "LeaderboardHighscores"

var _is_sdk_initialized : bool = false
var _is_player_initialized : bool = false
var _is_leaderboards_initialized : bool = false
var _yandexSDK = null

var _callback_sdk_initialized = JavaScript.create_callback(self, '_sdk_initialized')
var _callback_player_initialized = \
		JavaScript.create_callback(self, '_player_initialized')
var _callback_leaderboards_initialized = \
		JavaScript.create_callback(self, '_leaderboards_initialized')

var _callback_ad = JavaScript.create_callback(self, '_ad')
var _callback_rewarded_ad = JavaScript.create_callback(self, '_rewarded_ad')

var _callback_data_loaded_from_cloud = \
		JavaScript.create_callback(self, '_data_loaded_from_cloud')
var _callback_data_loaded_from_safe_storage = \
		JavaScript.create_callback(self, '_data_loaded_from_safe_storage')
var _callback_stats_loaded = JavaScript.create_callback(self, '_stats_loaded')

func _ready():
	_wait_for_sdk_object_initialization()

static func is_yandex():
	return OS.has_feature(_FEATURE_NAME)

func init_sdk():
	if is_yandex():
		_is_sdk_initialized = get_is_sdk_initialized()
		if !_is_sdk_initialized:
			_yandexSDK.initSDK(\
					_object_to_js_object({}), _callback_sdk_initialized)

func init_player():
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		_is_player_initialized = get_is_player_initialized()
		if !_is_player_initialized:
			_yandexSDK.initPlayer(false, _callback_player_initialized)

func init_leaderboards():
	if is_yandex():
		if !get_is_player_initialized():
			yield(self, "player_initialized")
		_is_leaderboards_initialized = get_is_leaderboards_initialized()
		if !_is_leaderboards_initialized:
			_yandexSDK.initLeaderboards(_callback_leaderboards_initialized)

func show_ad():
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		_yandexSDK.showAd(_callback_ad)

func show_rewarded_ad():
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		_yandexSDK.showAdRewardedVideo(_callback_rewarded_ad)

func save_data_to_cloud(data: Dictionary, flush: bool = false):
	if is_yandex():
		if !get_is_player_initialized():
			yield(self, "player_initialized")
		var saves = _object_to_js_object(data)
		_yandexSDK.saveDataToCloud(saves, flush)

func save_data_to_safe_storage(data : Dictionary):
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		var saves = _object_to_js_object(data)
		_yandexSDK.saveDataToSafeStorage(saves)

func save_stats(stats: Dictionary):
	if is_yandex():
		if !get_is_player_initialized():
			yield(self, "player_initialized")
		var saves = _object_to_js_object(stats)
		_yandexSDK.saveStats(saves)

func load_data_from_cloud(data : Array):
	if is_yandex():
		if !get_is_player_initialized():
			yield(self, "player_initialized")
		var saves = _object_to_js_object(data)
		_yandexSDK.loadDataFromCloud(saves, _callback_data_loaded_from_cloud)

func load_data_all_from_cloud():
	if is_yandex():
		if !get_is_player_initialized():
			yield(self, "player_initialized")
		_yandexSDK.loadDataAllFromCloud(_callback_data_loaded_from_cloud)

func get_cached_data_from_cloud():
	if is_yandex():
		if !get_is_player_initialized():
			yield(self, "player_initialized")
		var cached_data_js = _yandexSDK.getCachedDataFromCloud()
		return _js_object_to_object(cached_data_js)
	return {}

func load_data_from_safe_storage(data : Array):
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		var saves = _object_to_js_object(data)
		_yandexSDK.loadDataFromSafeStorage(saves, \
				_callback_data_loaded_from_safe_storage)

func load_data_all_from_safe_storage():
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		_yandexSDK\
				.loadDataAllFromSafeStorage(_callback_data_loaded_from_safe_storage)

func get_cached_data_from_safe_storage():
	if is_yandex():
		if !get_is_sdk_initialized():
			yield(self, "sdk_initialized")
		var cached_data_js = _yandexSDK.getCachedDataFromSafeStorage()
		return _js_object_to_object(cached_data_js)
	return {}

func load_stats(keys: Array):
	if is_yandex():
		if !get_is_player_initialized():
			yield(self, "player_initialized")
		var saves = _object_to_js_object(keys)
		_yandexSDK.loadStats(saves, _callback_stats_loaded)

func set_leaderboard_score(score : int, leaderboard_name : String = _LEADERBOARD_NAME):
	if is_yandex():
		if !get_is_leaderboards_initialized():
			yield(self, "leaderboards_initialized")
		var lb_name_js = _object_to_js_object(leaderboard_name)
		var user_score_js = _object_to_js_object(score)
		_yandexSDK.setLeaderboardScore(lb_name_js, user_score_js)

func get_locale():
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		return _yandexSDK.getLocale()
	return TranslationServer.get_locale()

func remove_data_from_safe_storage(keys : Array):
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		var keys_js = _object_to_js_object(keys)
		_yandexSDK.removeDataFromSafeStorage(keys_js)

func clear_safe_storage():
	if is_yandex():
		if !get_is_sdk_initialized() :
			yield(self, "sdk_initialized")
		_yandexSDK.clearSafeStorage()

func get_is_sdk_initialized():
	if is_yandex():
		if !_yandexSDK:
			yield(self, "sdk_object_initialized")
		_is_sdk_initialized = _yandexSDK.isSDKInitialized()
		return _is_sdk_initialized
	return false

func get_is_player_initialized():
	if is_yandex():
		if !_yandexSDK:
			yield(self, "sdk_object_initialized")
		_is_player_initialized = _yandexSDK.isPlayerInitialized()
		return _is_player_initialized
	return false

func get_is_leaderboards_initialized():
	if is_yandex():
		if !_yandexSDK:
			yield(self, "sdk_object_initialized")
		_is_leaderboards_initialized = _yandexSDK.isLeaderboardsInitialized()
		return _is_leaderboards_initialized
	return false

func _rewarded_ad(args):
	emit_signal("rewarded_ad", args)

func _ad(args):
	emit_signal("ad", args[0])

func _data_loaded_from_cloud(args):
	if args[0] == 'loaded':
		var result = _js_object_to_object(args[1])
		emit_signal("data_loaded_from_cloud", result)

func _data_loaded_from_safe_storage(data):
	var result = _js_object_to_object(data)
	emit_signal("data_loaded_from_safe_storage", result)

func _stats_loaded(args):
	if args[0] == 'loaded':
		var result = _js_object_to_object(args[1])
		emit_signal("stats_loaded", result)

func _sdk_initialized():
	_is_sdk_initialized = true
	_yandexSDK.initGame() # start metrics
	emit_signal('sdk_initialized')

func _player_initialized():
	_is_player_initialized = true
	emit_signal('player_initialized')

func _leaderboards_initialized():
	_is_leaderboards_initialized = true
	emit_signal("leaderboards_initialized")

func _wait_for_sdk_object_initialization():
	while !_yandexSDK:
		_yandexSDK = JavaScript.get_interface("yandexSDK")
		if _yandexSDK:
			break
		yield(get_tree(),"idle_frame")
	emit_signal("sdk_object_initialized")

func _object_to_js_object(obj):
	var obj_js
	if typeof(obj) == TYPE_ARRAY:
		obj_js = JavaScript.create_object("Array", obj.size())
		for idx in obj.size():
			obj_js[idx] = _object_to_js_object(obj[idx])
	elif typeof(obj) == TYPE_DICTIONARY:
		obj_js = JavaScript.create_object("Object")
		for key in obj.keys():
			obj_js[key] = _object_to_js_object(obj[key])
	else:
		if typeof(obj) == TYPE_INT || typeof(obj) == TYPE_REAL:
			obj_js = JavaScript.create_object("Number")
		elif typeof(obj) == TYPE_STRING:
			obj_js = JavaScript.create_object("String")
		elif typeof(obj) == TYPE_BOOL:
			obj_js = JavaScript.create_object("Boolean")
		else:
			return null
		obj_js = obj
	return obj_js

func _js_object_to_object(obj_js):
	var obj
	if typeof(obj_js) == TYPE_OBJECT: # dictionary
		var i_object = JavaScript.get_interface("Object")
		var i_array = JavaScript.get_interface("Array")
		if i_array.isArray(obj_js):
			obj = []
			for idx in obj_js.length:
				obj.append(_js_object_to_object(obj_js[idx]))
		else:
			var keys = i_object.keys(obj_js)
			var values = i_object.values(obj_js)
			obj = {}
			for idx in keys.length:
				obj[keys[idx]] = _js_object_to_object(values[idx])
	elif typeof(obj_js) == TYPE_ARRAY:
		obj = []
		for idx in obj_js.length:
			obj[idx] = _js_object_to_object(obj_js[idx])
	else:
		obj = obj_js
	return obj
