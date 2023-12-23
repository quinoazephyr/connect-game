class_name ScreenshotScene
extends GameplaySceneBase

export(int) var _board_id = 0
export(Array) var _dots_color_ids

var _gameplay = null

onready var _gameplay4x4 = $Gameplay4x4
onready var _gameplay6x8 = $Gameplay6x8

func _on_ready():
	if _dots_color_ids[_board_id].size() == 16:
		_gameplay = _gameplay4x4
	elif _dots_color_ids[_board_id].size() == 48:
		_gameplay = _gameplay6x8
	
	_connect_game_input()
	_gameplay.connect_game_input(_game_input)
	_generate_dots()

func _connect_game_input():
	_game_input.connect("input_enabled", _gameplay, "connect_game_input", \
			[_game_input])
	_game_input.connect("input_disabled", _gameplay, "disconnect_game_input", \
			[_game_input])

func _disconnect_game_input():
	_game_input.disconnect("input_enabled", _gameplay, "connect_game_input")
	_game_input.disconnect("input_disabled", _gameplay, "disconnect_game_input")

func _generate_dots():
	var dots_obj = _gameplay._dots
	var dots_arr = dots_obj._dots
	_reset_colors(dots_obj, dots_arr)
	dots_obj.call_deferred("_update_dots_positions")

func _reset_colors(dots_obj, dots_arr):
	dots_obj._clear_all_dots()
	var dots_colors_ids = _dots_color_ids[_board_id]
	var new_dots : Array = [] # [idx, dot]
	for idx in dots_colors_ids.size():
		if dots_arr[idx]:
			continue
		var row = dots_obj._get_row(idx)
		var column = dots_obj._get_column(idx)
		var color = dots_obj._colors.get_color(dots_colors_ids[idx]).to_html()
		var dot = dots_obj._instantiate_dot(row, column, color, null)
		new_dots.append([idx, dot])
		dots_arr[idx] = dot
	
	var new_dots_only : Array = []
	for d in new_dots:
		var dot = d[1]
		new_dots_only.append(dot)
	dots_obj.emit_signal("dots_generated", new_dots_only)
