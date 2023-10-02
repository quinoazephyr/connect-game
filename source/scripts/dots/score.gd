class_name Score
extends Saveable

const _SCORE_PREF = "score"

export(NodePath) var _dots_path
export(Array) var _scores_and_colors_count # ARRAY OF ARRAYS: [score, color_count]

var _score : int

onready var _score_label = $"."
onready var _add_score_label = $AddScoreLabel
onready var _score_font = _score_label.get("custom_fonts/font")
onready var _add_score_font = _add_score_label.get("custom_fonts/font")
onready var _dots = get_node(_dots_path)

func _ready():
	_dots.connect("dot_connected", self, "_on_dot_connected")
	_dots.connect("dots_selected", self, "_on_dots_selected")
	_dots.connect("dot_disconnected", self, "_on_dot_disconnected")
	_dots.connect("dots_removed", self, "_on_dots_removed")
	
	_dots._game_input.connect("input_just_released", self, "_on_input_release")

func reset_score():
	set_score(0)

func set_score(val : int):
	_score = val
	_score_label.text = "%d" % _score

func get_score():
	return _score

func save_me(player_prefs : PlayerPrefs):
	player_prefs.set_pref(_SCORE_PREF, get_score())

func load_me(player_prefs : PlayerPrefs):
	if player_prefs.has_pref(_SCORE_PREF):
		set_score(player_prefs.get_pref(_SCORE_PREF))
	else:
		reset_score()

func get_color_count(score_val : int):
	for i in range(_scores_and_colors_count.size(), 0, -1):
		var idx = i - 1
		var pair = _scores_and_colors_count[idx]
		var score = pair[0]
		var color_count = pair[1]
		if score_val > score:
			return color_count
	return 1

func _on_input_release(mouse_pos):
	_show_add_score_label(false)

func _show_add_score_label(show : bool):
	_add_score_label.visible = show

func _on_dot_connected(dot : Dot):
	_on_dots_selected(_dots._connected_dots)

func _on_dot_disconnected(dot : Dot):
	if _dots._connected_dots.size() == 0:
		_show_add_score_label(false)
	else:
		_on_dots_selected(_dots._connected_dots)

func _on_dots_selected(dots : Array):
	var connected_dots_size = dots.size()
	_show_add_score_label(true)
	_add_score_label.text = "+%d" % connected_dots_size
	_reposition_add_score_rect()

func _on_dots_removed(dots : Array):
	set_score(_score + dots.size())
	_dots.current_colors_count = get_color_count(get_score())

func _reposition_add_score_rect():
	var score_font_rect_size = _score_font.get_string_size(_score_label.text)
	var add_score_font_rect_size = _add_score_font.get_string_size(_add_score_label.text)
	var score_rect_size = _score_label.rect_size
	_add_score_label.rect_position = \
			Vector2(score_font_rect_size.x / 2.0, -32.0)
