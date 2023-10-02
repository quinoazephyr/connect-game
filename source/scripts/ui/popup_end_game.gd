class_name PopupEndGame
extends PopupWithBackground

export(Array) var _watch_ad_config_enabled # texture, color icon, color text
export(Array) var _watch_ad_config_disabled # texture, color icon, color text

onready var _final_score_label = $PopupDialog/VBoxContainer/VBoxScore/FinalScore
onready var _score_label = $PopupDialog/VBoxContainer/VBoxScore/ScoreLabel
onready var _new_highscore_label = $PopupDialog/VBoxContainer/VBoxScore/NewHighscoreLabel
onready var _new_game_button = $PopupDialog/VBoxContainer/VBoxButtons/NewGameButton
onready var _watch_ad_button = $PopupDialog/VBoxContainer/VBoxButtons/WatchAdButton
onready var _ad_icon = $PopupDialog/VBoxContainer/VBoxButtons/WatchAdButton/TextureRect
onready var _ad_label = $PopupDialog/VBoxContainer/VBoxButtons/WatchAdButton/Label

func set_new_game_button_callback(target : Object, method : String):
	_new_game_button.connect("pressed", target, method)

func set_watch_ad_button_callback(target : Object, method : String):
	_watch_ad_button.connect("pressed", target, method)

func set_score_label(score : int, is_highscore : bool):
	_final_score_label.text = "%d" % score
	_score_label.visible = !is_highscore
	_new_highscore_label.visible = is_highscore

func set_watch_button_enabled(is_enabled : bool):
	var button_config = _watch_ad_config_enabled if is_enabled \
			else _watch_ad_config_disabled
	_watch_ad_button.icon = button_config[0]
	_ad_icon.self_modulate = button_config[1]
	_ad_label.self_modulate = button_config[2]
	_watch_ad_button.disabled = !is_enabled
