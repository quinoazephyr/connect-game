class_name Dots
extends Node

signal dot_connected(dot)
signal dot_disconnected(dot)
signal dots_selected(dots)
signal dots_looped(dots)
signal dots_connected_removed(dots)
signal dots_removed(dots)
signal dots_moved(existing_dots, new_dots)

const _DOTS_SPECIAL_LOOP_MIN_COUNT = 4

export(NodePath) var _game_input_path
export(NodePath) var _connecting_line_path
export(NodePath) var _colorblind_mode_path
export(PackedScene) var _dot_packed_scene
export(Resource) var _colors

var current_colors_count = 1

var _dots : Array
var _connected_dots : Array

onready var _viewport = get_viewport()
onready var _viewport_size = _viewport.size
onready var _canvas_item = $CanvasLayer/Control # for resize callback
onready var _new_dots_positions_parent = $CanvasLayer/NewDotsPositions
onready var _dots_positions_parent = $CanvasLayer/DotsPositions
onready var _columns_count = _dots_positions_parent.columns
onready var _rows_count = _dots_positions_parent.get_child_count() / \
		_columns_count
onready var _game_input = get_node(_game_input_path)
onready var _connecting_line = get_node(_connecting_line_path)
onready var _colorblind_mode = get_node(_colorblind_mode_path)
onready var _colors_generation_strategy = ColorsGenerationStrategy0.new()

func _ready():
	_canvas_item.connect("resized", self, \
			"_call_deferred_update_dots_positions")
	
	_game_input.connect("input_just_pressed", self, "_on_input_pressed")
	_game_input.connect("input_just_released", self, "_on_input_released")
	_game_input.connect("input_motion_drag", self, "_on_input_dragged")
	
	_colorblind_mode.connect("colorblind_changed", self, "_show_colorblind_sprites")

static func is_loop_exists(dots : Array):
	for dot in dots:
		if get_dot_count_between_dots(dots, dot, dot) > 0:
			return true
	return false

static func get_dot_count_between_dots(dots : Array, dot_begin : Dot, dot_end : Dot):
	var dot_begin_idx = dots.find(dot_begin)
	var dot_end_idx = dots.rfind(dot_end)
	if dot_begin_idx == -1 || dot_end_idx == -1:
		return 0
	return dot_end_idx - dot_begin_idx

static func sort_by_null_ascending(a, b):
	return a == null

func generate_new():
	for idx in _dots.size():
		var dot = _dots[idx]
		_dots[idx] = null
		dot.queue_free()
	
	if !_dots || _dots.size() == 0:
		for i in _dots_positions_parent.get_child_count():
			_dots.append(null)
	
	_colors_generation_strategy.reset_counter()
	_fill_empty_positions()
	_call_deferred_update_dots_positions()

func _on_input_pressed(mouse_pos):
	var dot = _get_dot_under_cursor(mouse_pos)
	if dot:
		_connected_dots.clear()
		_connect_new_dot(dot)
		_connecting_line.create_line(dot.center_position, dot.center_position, dot.color)

func _on_input_released(mouse_pos):
	if _connected_dots.size() > 1:
		var last_dot = _connected_dots.back()
		if get_dot_count_between_dots(_connected_dots, last_dot, last_dot) > \
				_DOTS_SPECIAL_LOOP_MIN_COUNT - 1:
					emit_signal("dots_connected_removed", _connected_dots)
					var color_id_to_remove = last_dot.color_id
					_connected_dots.clear()
					for dot in _dots:
						if dot.color_id == color_id_to_remove:
							_connected_dots.append(dot)
		else:
			emit_signal("dots_connected_removed", _connected_dots)
		_accept_and_remove_connected_dots()
		_prepare_board_after_dots_removal()
	_connected_dots.clear()
	_connecting_line.clear_line()

func _on_input_dragged(mouse_pos):
	if _connected_dots.size() > 0:
		var dot = _get_dot_under_cursor(mouse_pos)
		var last_connected_dot = _connected_dots.back()
		if dot:
			if _can_disconnect_dots(last_connected_dot, dot):
				_disconnect_dot(last_connected_dot)
				_connecting_line.remove_last_point()
			elif _can_connect_new_dot(last_connected_dot, dot) && !is_loop_exists(_connected_dots):
				_connect_new_dot(dot)
				_connecting_line.set_line_end(dot.center_position)
				_connecting_line.add_point(mouse_pos)
				if is_loop_exists(_connected_dots):
					_connecting_line.set_line_end(dot.center_position)
					if get_dot_count_between_dots(_connected_dots, dot, dot) > _DOTS_SPECIAL_LOOP_MIN_COUNT - 1:
						var dots_one_color : Array
						for d in _dots:
							if d.color_id == dot.color_id:
								dots_one_color.append(d)
						var dots_loop : Array
						var dot_begin_idx = _connected_dots.find(dot)
						var dot_end_idx = _connected_dots.rfind(dot)
						for idx in range(dot_begin_idx, dot_end_idx):
							dots_loop.append(_connected_dots[idx])
						emit_signal("dots_looped", dots_loop)
						emit_signal("dots_selected", dots_one_color)
		if !is_loop_exists(_connected_dots):
			_connecting_line.set_line_end(mouse_pos)

func _instantiate_dot(row : int, column : int, \
		color : Color, colorblind_texture : Texture):
	var dot = _dot_packed_scene.instance()
	add_child(dot)
	dot.initialize(row, column, color.to_html(), colorblind_texture)
	return dot

func _remove_dot(dot : Dot): # DOES NOT REMOVE FROM TREE - expected!!!
	var idx = _get_idx(dot.row, dot.column)
	_dots[idx] = null

func _accept_and_remove_connected_dots():
	var removed_ids : Array
	for connected_dot in _connected_dots:
		var idx = _get_idx(connected_dot.row, connected_dot.column)
		if removed_ids.find(idx) != -1:
			continue
		removed_ids.append(idx)
		_remove_dot(connected_dot)
	emit_signal("dots_removed", _connected_dots)
	_connected_dots.clear()

func _prepare_board_after_dots_removal():
	var existing_dots_to_move : Array
	for c in _columns_count:
		var cur_row_dots : Array
		var nulls_count = 0
		for r in _rows_count:
			cur_row_dots.append(_dots[_get_idx(r, c)])
			if !_dots[_get_idx(r, c)]:
				nulls_count += 1
		
		if nulls_count > 0:
			cur_row_dots.sort_custom(self, "sort_by_null_ascending")
			for r in range(_rows_count - 1, 0, -1):
				if !cur_row_dots[r]:
					break
				if cur_row_dots[r].row != r:
					existing_dots_to_move.append(cur_row_dots[r])
					cur_row_dots[r].initialize(r, c, cur_row_dots[r].color_id, \
							cur_row_dots[r].colorblind_sprite)
		
		for n in nulls_count:
			for r in range(_rows_count - 1, 0, -1):
				if !_dots[_get_idx(r, c)]:
					_dots[_get_idx(r, c)] = _dots[_get_idx(r - 1, c)]
					_dots[_get_idx(r - 1, c)] = null
	
	var empty_dots_ids : Array
	for i in _dots.size():
		if _dots[i]:
			continue
		empty_dots_ids.append(i)
	
	_fill_empty_positions()
	
	var new_dots_to_move : Array
	for idx in empty_dots_ids:
		new_dots_to_move.append(_dots[idx])
	
	emit_signal("dots_moved", existing_dots_to_move, new_dots_to_move)

func _fill_empty_positions():
	var new_dots : Array = [] # [idx, dot]
	for i in range(_dots.size(), 0, -1):
		var idx = i - 1
		if _dots[idx]:
			continue
		var dot = _generate_dot_in_empty_position(idx, false)
		new_dots.append([idx, dot])
		_dots[idx] = dot
	
	while !_is_connections_available():
		for idx in new_dots.size():
			var dot_idx = new_dots[idx][0]
			var dot_old = new_dots[idx][1]
			var regen_dot = _generate_dot_in_empty_position(dot_idx, true)
			new_dots[idx] = [dot_idx, regen_dot]
			_dots[dot_idx] = regen_dot
			dot_old.queue_free()

func _generate_dot_in_empty_position(idx : int, is_regenerate : bool):
	var row = _get_row(idx)
	var column = _get_column(idx)
	var color = _colors_generation_strategy \
			.regenerate_color(_dots, _colors, _columns_count, \
			row, column, current_colors_count) if is_regenerate \
			else \
			_colors_generation_strategy \
				.generate_color(_dots, _colors, _columns_count, \
				row, column, current_colors_count)
	var colorblind_texture = \
			_colorblind_mode.get_texture(_colors.get_color_idx(color))
	var dot = _instantiate_dot(row, column, color, colorblind_texture)
	dot.show_colorblind_sprite(_colorblind_mode.is_active)
	return dot

func _connect_new_dot(dot : Dot):
	_connected_dots.append(dot)
	emit_signal("dot_connected", dot)

func _disconnect_dot(dot : Dot):
	_connected_dots.remove(_connected_dots.rfind(dot))
	emit_signal("dot_disconnected", dot)

func _get_dot_under_cursor(mouse_pos : Vector2):
	for dot in _dots:
		if dot.is_contains_mouse(mouse_pos):
			return dot
	return null

func _can_disconnect_dots(last_connected_dot, dot):
	return last_connected_dot != dot && _connected_dots.size() > 1 && \
			_connected_dots[_connected_dots.size() - 2] == dot

func _can_connect_new_dot(last_connected_dot, dot):
	var dots_distance = Vector2(dot.row - last_connected_dot.row, \
			dot.column - last_connected_dot.column).length()
	return last_connected_dot != dot && \
			last_connected_dot.color_id == dot.color_id && \
			dots_distance < 2.0 && \
			!_connecting_line.is_line_exists(last_connected_dot.center_position, \
					dot.center_position)

func _is_connections_available(): # can connect any dots?
	for idx in _dots.size():
		var dot = _dots[idx]
		if !dot:
			continue
		var adjacent_dots = \
				_colors_generation_strategy\
				.get_adjacent_dots(_dots, _columns_count, dot.row, dot.column)
		for adj_dot in adjacent_dots:
			if adj_dot.color.to_html() == dot.color.to_html():
				return true
	return false

func _show_colorblind_sprites(is_enabled : bool):
	for dot in _dots:
		dot.show_colorblind_sprite(is_enabled)

func _get_row(idx : int):
	return idx / _columns_count

func _get_column(idx : int):
	return idx % _columns_count

func _get_idx(row : int, col : int):
	return row * _columns_count + col

func _get_dot(row : int, col : int):
	var idx = _get_idx(row, col)
	if idx < 0 || idx >= _dots.size():
		return null
	return _dots[idx]

func _call_deferred_update_dots_positions():
	call_deferred("_update_dots_positions")

func _update_dots_positions():
	for i in _dots.size():
		_dots[i].global_position = \
				_dots_positions_parent.get_child(i).rect_global_position
