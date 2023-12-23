class_name Highscore
extends Saveable

signal highscore_set

const _HIGHSCORE_PREF = "highscore"

var _highscore : int

onready var _highscore_label = $HighscoreLabel

func evaluate_and_set_highscore(score : int):
	var old_highscore = get_highscore()
	var new_highscore = max(old_highscore, score)
	if new_highscore != old_highscore:
		set_highscore(new_highscore)

func set_highscore(value : int):
	_highscore = value
	_highscore_label.text = "%d" % _highscore
	emit_signal("highscore_set")

func get_highscore():
	return _highscore

func save_me(player_prefs : PlayerPrefs):
	player_prefs.set_pref(_HIGHSCORE_PREF, get_highscore())

func load_me(player_prefs : PlayerPrefs):
	set_highscore(max(player_prefs.get_pref(_HIGHSCORE_PREF), get_highscore()))
