class_name Dots
extends Saveable

signal dot_connected(dot)
signal dot_disconnected(dot)
signal dots_selected(dots)
signal dots_looped(dots)
signal dots_removed_special_loop(dots)
signal dots_removed(dots)
signal dots_moved(columns_count, existing_dots, existing_dots_target_positions, \
		new_dots, new_dots_target_positions)
signal dots_generated(dots)

const _DOTS_PREF = "dots"
const _COLORS_COUNT_PREF = "colors_count"
const _GENERATION_STRATEGY_COUNT_PREF = "generations_count"
const _DOTS_SPECIAL_LOOP_MIN_COUNT = 4

export(PackedScene) var _dot_packed_scene
export(Resource) var _colors

var _current_colors_count = 4

var _dots : Array
var _connected_dots : Array

onready var _viewport = get_viewport()
onready var _viewport_size = _viewport.size
onready var _canvas_item = $CanvasLayer/Control # for resize callback
onready var _dots_positions_parent = $CanvasLayer/DotsPositions
onready var _columns_count = _dots_positions_parent.columns
onready var _rows_count = _dots_positions_parent.get_child_count() / \
		_columns_count
onready var _colors_generation_strategy = ColorsGenerationStrategy0.new()

func _ready():
	_canvas_item.connect("resized", self, "_update_dots_positions", [], \
			CONNECT_DEFERRED)

static func is_loop_exists(dots : Array):
	for dot in dots:
		if get_dot_count_between_dots(dots, dot, dot) > 0:
			return true
	return false

static func is_loop_special_exists(dots : Array):
	for dot in dots:
		if get_dot_count_between_dots(dots, dot, dot) > \
				_DOTS_SPECIAL_LOOP_MIN_COUNT - 1:
			return true
	return false

static func get_dot_count_between_dots(dots : Array, dot_begin : Dot, dot_end : Dot):
	var dot_begin_idx = dots.find(dot_begin)
	var dot_end_idx = dots.rfind(dot_end)
	if dot_begin_idx == -1 || dot_end_idx == -1:
		return 0
	return dot_end_idx - dot_begin_idx

static func get_loop(dots : Array, dot_begin : Dot, dot_end : Dot):
	var dots_loop : Array
	var dot_begin_idx = dots.find(dot_begin)
	var dot_end_idx = dots.rfind(dot_end)
	for idx in range(dot_begin_idx, dot_end_idx):
		dots_loop.append(dots[idx])
	return dots_loop

static func sort_by_null_ascending(a, b):
	return a == null

func show_colorblind_sprites_all(is_show : bool):
	show_colorblind_sprites(_dots, is_show)

func show_colorblind_sprites(dots : Array, is_show : bool):
	for dot in dots:
		dot.show_colorblind_sprite(is_show)

func generate_new(colors_count : int):
	_clear_all_dots()
	_colors_generation_strategy.reset_counter()
	set_colors_count(colors_count)
	_fill_empty_positions()
	call_deferred("_update_dots_positions")

func get_dot_at_position(pos : Vector2):
	for dot in _dots:
		if dot.is_contains_mouse(pos):
			return dot
	return null

func is_loop_in_connection():
	return is_loop_exists(_connected_dots)

func is_loop_in_connection_special():
	return get_special_loop_dot_count_in_connection() > \
			_DOTS_SPECIAL_LOOP_MIN_COUNT - 1

func get_special_loop_dot_count_in_connection():
	var last_connected_dot = _connected_dots.back()
	return get_dot_count_between_dots(_connected_dots, \
			last_connected_dot, last_connected_dot)

func get_connected_dots_count():
	return _connected_dots.size()

func notify_of_connected_special_loop(last_connected_dot : Dot):
	var dots_loop = get_loop(_connected_dots, \
			last_connected_dot, last_connected_dot)
	emit_signal("dots_looped", dots_loop)

func select_all_dots_of_color(color_id):
	var dots_one_color : Array
	for d in _dots:
		if d.color_id == color_id:
			dots_one_color.append(d)
	emit_signal("dots_selected", dots_one_color)

func can_connect_dot(dot : Dot):
	var last_connected_dot = _connected_dots.back()
	return _can_connect_new_dot(last_connected_dot, dot)

func can_disconnect_last_dot_after_current_dot(current_dot : Dot):
	var last_connected_dot = _connected_dots.back()
	return _can_disconnect_dots(last_connected_dot, current_dot)

func connect_dot(dot : Dot):
	_connected_dots.append(dot)
	emit_signal("dot_connected", dot)

func disconnect_dot(dot : Dot):
	_connected_dots.remove(_connected_dots.rfind(dot))
	emit_signal("dot_disconnected", dot)

func disconnect_last_dot():
	var last_connected_dot = _connected_dots.back()
	disconnect_dot(last_connected_dot)

func reset_connected_dots():
	_connected_dots.clear()

func is_any_dot_connected():
	return _connected_dots.size() > 0

func set_colors_count(count : int):
	_current_colors_count = count

func get_colors_count():
	return _current_colors_count

func try_remove_connected_dots():
	if _connected_dots.size() > 1:
		var dots_to_remove : Array
		var last_dot = _connected_dots.back()
		if get_dot_count_between_dots(_connected_dots, last_dot, last_dot) > \
				_DOTS_SPECIAL_LOOP_MIN_COUNT - 1:
			var color_id_to_remove = last_dot.color_id
			for dot in _dots:
				if dot.color_id == color_id_to_remove:
					dots_to_remove.append(dot)
			emit_signal("dots_removed_special_loop", _connected_dots)
		else:
			dots_to_remove = _connected_dots
		_remove_dots(dots_to_remove)
		_prepare_board_after_dots_removal()

func save_me(player_prefs : PlayerPrefs):
	var dot_colors : Array
	for dot in _dots:
		dot_colors.append(_colors.get_color_idx(dot.color))
	player_prefs.set_pref(_DOTS_PREF, dot_colors)
	player_prefs.set_pref(_COLORS_COUNT_PREF, get_colors_count())
	player_prefs.set_pref(_GENERATION_STRATEGY_COUNT_PREF, \
			_colors_generation_strategy.get_counter())

func load_me(player_prefs : PlayerPrefs):
	if player_prefs.has_pref(_DOTS_PREF):
		var dot_colors = player_prefs.get_pref(_DOTS_PREF)
		var colors_count = player_prefs.get_pref(_COLORS_COUNT_PREF)
		var gen_strategy_counter = \
				player_prefs.get_pref(_GENERATION_STRATEGY_COUNT_PREF)
		
		_clear_all_dots()
		_colors_generation_strategy.set_counter(gen_strategy_counter)
		set_colors_count(colors_count)
		
		for idx in dot_colors.size():
			var row = _get_row(idx)
			var column = _get_column(idx)
			var color = _colors.get_color(dot_colors[idx])
			var colorblind_texture = \
					_colors.get_colorblind_sprite(_colors.get_color_idx(color))
			var dot = _instantiate_dot(row, column, color, colorblind_texture)
			_dots[idx] = dot
		
		call_deferred("_update_dots_positions")

func _instantiate_dot(row : int, column : int, \
		color : Color, colorblind_texture : Texture):
	var dot = _dot_packed_scene.instance()
	add_child(dot)
	dot.initialize(row, column, color.to_html(), colorblind_texture)
	return dot

func _remove_dot(dot : Dot): # DOES NOT REMOVE FROM TREE - expected!!!
	var idx = _get_idx(dot.row, dot.column)
	_dots[idx] = null

func _remove_dots(dots_to_remove : Array):
	if dots_to_remove.size() == 0:
		return
	var removed_ids : Array
	for dot in dots_to_remove:
		var idx = _get_idx(dot.row, dot.column)
		if removed_ids.find(idx) != -1:
			continue
		removed_ids.append(idx)
		_remove_dot(dot)
	emit_signal("dots_removed", dots_to_remove)
	reset_connected_dots()

func _prepare_board_after_dots_removal():
	var existing_dots_to_move : Array
	var existing_dots_target_positions : Array
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
					var idx = _get_idx(r, c)
					existing_dots_to_move.append(cur_row_dots[r])
					existing_dots_target_positions.append(\
							_dots_positions_parent\
							.get_child(idx).rect_global_position)
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
	var new_dots_target_positions : Array
	for idx in empty_dots_ids:
		new_dots_to_move.append(_dots[idx])
		new_dots_target_positions.append(_dots_positions_parent\
				.get_child(idx).rect_global_position)
	
	emit_signal("dots_moved", _columns_count, \
			existing_dots_to_move, existing_dots_target_positions, \
			new_dots_to_move, new_dots_target_positions)

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
	
	var new_dots_only : Array = []
	for d in new_dots:
		var dot = d[1]
		new_dots_only.append(dot)
	emit_signal("dots_generated", new_dots_only)

func _generate_dot_in_empty_position(idx : int, is_regenerate : bool):
	var row = _get_row(idx)
	var column = _get_column(idx)
	var color = _colors_generation_strategy \
			.regenerate_color(_dots, _colors, _columns_count, \
			row, column, _current_colors_count) if is_regenerate \
			else \
			_colors_generation_strategy \
				.generate_color(_dots, _colors, _columns_count, \
				row, column, _current_colors_count)
	var colorblind_texture = \
			_colors.get_colorblind_sprite(_colors.get_color_idx(color))
	var dot = _instantiate_dot(row, column, color, colorblind_texture)
	return dot

func _can_disconnect_dots(last_connected_dot, dot):
	return last_connected_dot != dot && _connected_dots.size() > 1 && \
			_connected_dots[_connected_dots.size() - 2] == dot

func _can_connect_new_dot(last_connected_dot, dot):
	var dots_distance = Vector2(dot.row - last_connected_dot.row, \
			dot.column - last_connected_dot.column).length()
	return last_connected_dot != dot && \
			last_connected_dot.color_id == dot.color_id && \
			dots_distance < 2.0# && \
#			!_connecting_line.is_line_exists(last_connected_dot.center_position, \
#					dot.center_position)

func _is_connections_available(): # can connect any dots?
	for idx in _dots.size():
		var dot = _dots[idx]
		if !dot:
			continue
		var adjacent_dots = \
				_colors_generation_strategy\
				.get_adjacent_dots_right_bottom(\
				_dots, _columns_count, dot.row, dot.column)
		for adj_dot in adjacent_dots:
			if adj_dot.color.to_html() == dot.color.to_html():
				return true
	return false

func _clear_all_dots():
	for idx in _dots.size():
		var dot = _dots[idx]
		_dots[idx] = null
		dot.queue_free()
	
	if !_dots || _dots.size() == 0:
		for i in _dots_positions_parent.get_child_count():
			_dots.append(null)

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

func _update_dots_positions():
	for i in _dots.size():
		_dots[i].global_position = \
				_dots_positions_parent.get_child(i).rect_global_position
