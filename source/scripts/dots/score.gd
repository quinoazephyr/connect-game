class_name Score
extends Saveable

const _SCORE_PREF = "score"

export(Array) var _scores_and_colors_count # ARRAY OF ARRAYS: [score, color_count]

var _score : int

onready var _score_label = $ScoreLabel
onready var _add_score_label = $ScoreLabel/AddScoreLabel
onready var _score_font = _score_label.get("custom_fonts/font")
onready var _add_score_font = _add_score_label.get("custom_fonts/font")

func reset_score():
	set_score(0)

func set_score(val : int):
	_score = val
	_score_label.text = "%d" % _score

func get_score():
	return _score

func set_additional_score(val : int):
	_add_score_label.text = "+%d" % val

func save_me(player_prefs : PlayerPrefs):
	player_prefs.set_pref(_SCORE_PREF, get_score())

func load_me(player_prefs : PlayerPrefs):
	if player_prefs.has_pref(_SCORE_PREF):
		set_score(player_prefs.get_pref(_SCORE_PREF))
	else:
		reset_score()

func clear_saved_data(player_prefs : PlayerPrefs):
	player_prefs.remove_pref(_SCORE_PREF)

func get_color_count():
	for i in range(_scores_and_colors_count.size(), 0, -1):
		var idx = i - 1
		var pair = _scores_and_colors_count[idx]
		var score = pair[0]
		var color_count = pair[1]
		if _score > score:
			return color_count
	return 1

func show_add_score_label(show : bool):
	_add_score_label.visible = show

func _reposition_add_score_rect():
	var score_font_rect_size = _score_font.get_string_size(_score_label.text)
	var add_score_font_rect_size = _add_score_font.get_string_size(_add_score_label.text)
	var score_rect_size = _score_label.rect_size
	_add_score_label.rect_position = \
			Vector2(score_font_rect_size.x / 2.0, -32.0)
