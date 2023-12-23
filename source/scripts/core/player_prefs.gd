class_name PlayerPrefs
extends Node

const _DEFAULT_FILENAME = "res://source/resources/default_player_prefs"
const _FILENAME = "user://player_prefs"

var _settings : Dictionary

func _ready():
	if !_file_exists():
		_create_file(_DEFAULT_FILENAME)
		save_data(_FILENAME)
	load_data(_FILENAME)

func has_pref(property):
	return _settings.has(property)

func get_pref(property, default_return = 0):
	if has_pref(property):
		return _settings[property]
	return default_return

func set_pref(property, value):
	_settings[property] = value

func remove_pref(property):
	_settings.erase(property)
	save_data()

func remove_prefs(properties):
	for pref in properties:
		_settings.erase(pref)
	save_data()

func save_data(path = _FILENAME):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(to_json(_settings))
	file.close()

func load_data(path = _FILENAME):
	var file = File.new()
	file.open(path, File.READ)
	var json = JSON.parse(file.get_as_text())
	file.close()
	if json.get_error() == OK:
		_settings = json.result

func clear_all(path = _FILENAME):
	if _file_exists(path):
		var dir = Directory.new()
		dir.remove(path)
	_settings.clear()

func _file_exists(path = _FILENAME):
	var save_file = File.new()
	return save_file.file_exists(path)

func _create_file(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.close()
