class_name Moves
extends Saveable

signal no_moves_left

const _INITIAL_MOVES_COUNT = 20
const _MOVES_PREF = "moves"

var _moves : int

onready var _moves_label = $MovesContainer/MovesLabel
onready var _add_moves_label = $MovesContainer/MovesLabel/AddMovesLabel
onready var _moves_font = _moves_label.get("custom_fonts/font")
onready var _add_moves_font = _add_moves_label.get("custom_fonts/font")

func reset_moves():
	set_moves(_INITIAL_MOVES_COUNT)

func set_moves(val : int):
	_moves = max(0, val)
	_moves_label.text = "%d" % _moves
	if _moves == 0:
		call_deferred("emit_signal", "no_moves_left")

func get_moves():
	return _moves

func add_moves(count : int):
	set_moves(get_moves() + count)

func set_additional_moves(val : int):
	if val < 0:
		_add_moves_label.text = "%d" % val
	elif val > 0:
		_add_moves_label.text = "+%d" % val
	_reposition_add_moves_rect()

func save_me(player_prefs : PlayerPrefs):
	player_prefs.set_pref(_MOVES_PREF, _moves)

func load_me(player_prefs : PlayerPrefs):
	if player_prefs.has_pref(_MOVES_PREF):
		set_moves(player_prefs.get_pref(_MOVES_PREF))
	else:
		reset_moves()

func clear_saved_data(player_prefs : PlayerPrefs):
	player_prefs.remove_pref(_MOVES_PREF)

func show_add_moves_label(show : bool):
	_add_moves_label.visible = show

func _reposition_add_moves_rect():
	var moves_font_rect_size = _moves_font.get_string_size(_moves_label.text)
	var add_moves_font_rect_size = _add_moves_font.get_string_size(_add_moves_label.text)
	var moves_rect_size = _moves_label.rect_size
	_add_moves_label.rect_position = \
			Vector2(moves_rect_size.x / 2.0 + moves_font_rect_size.x / 2.0 - \
			add_moves_font_rect_size.x / 2.0, -32.0)
#	_add_moves_label.rect_pivot_offset = _add_moves_label.rect_size / 2.0

func _tween_add_moves_rect():
	var tween = get_tree().create_tween()
	tween.tween_property(_add_moves_label, "rect_scale", Vector2.ONE * 1.5, 0.25)
	tween.tween_property(_add_moves_label, "rect_scale", Vector2.ONE * 1.0, 0.25)
