class_name AdditionalMovesLabels
extends Node

const _KEYS_MOVES = [
	"KEY_MOVES_PLURAL",
	"KEY_MOVES_SINGULAR",
	"KEY_MOVES_2",
	"KEY_MOVES_2",
	"KEY_MOVES_2",
	"KEY_MOVES_PLURAL"
]

onready var _count_label = $CountLabel
onready var _moves_label = $MovesLabel

func set_moves_count(moves_count : int, is_lower_case : bool = true):
	_count_label.text = "%d " % moves_count
	_moves_label.text = "%s%s" % [_get_key_moves_str(moves_count),\
			"_LOWER" if is_lower_case else ""]

func _get_key_moves_str(moves_count : int):
	return _KEYS_MOVES[int(clamp(moves_count, 0, _KEYS_MOVES.size() - 1))]
