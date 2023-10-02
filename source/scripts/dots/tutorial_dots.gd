class_name TutorialDots
extends Node

signal all_dots_removed
signal dot_connected(dot)
signal dot_disconnected(dot)
signal dots_selected(dots)
signal dots_looped(dots)
signal dots_connected_removed(dots)
signal dots_removed(dots)
signal dots_moved(existing_dots, new_dots)

export(PackedScene) var _dot_packed_scene
export(Array) var _dots_positions_paths
export(Array) var _dots_colors_ids_arrays
export(Resource) var _colors_resource
export(NodePath) var _game_input_path
export(NodePath) var _connecting_line_path
export(NodePath) var _colorblind_mode_path

var _dots_positions : Array
var _dots : Array
var _connected_dots : Array
var _current_step_idx : int = -1

onready var _control_node = $CanvasLayer/Control
onready var _game_input = get_node(_game_input_path)
onready var _connecting_line = get_node(_connecting_line_path)
onready var _colorblind_mode = get_node(_colorblind_mode_path)

func _ready():
	for path in _dots_positions_paths:
		_dots_positions.append(get_node(path))
	
	_game_input.connect("input_just_pressed", self, "_on_input_pressed")
	_game_input.connect("input_just_released", self, "_on_input_released")
	_game_input.connect("input_motion_drag", self, "_on_input_dragged")
	
	_colorblind_mode.connect("colorblind_changed", self, "_show_colorblind_sprites")

func spawn_dots_step(step_idx : int):
	_current_step_idx = step_idx
	_spawn_dots(_dots_positions[step_idx], _dots_colors_ids_arrays[step_idx])

func _on_input_pressed(mouse_pos):
	var dot = _get_dot_under_cursor(mouse_pos)
	if dot:
		_connected_dots.clear()
		_connected_dots.append(dot)
		emit_signal("dot_connected", dot)
		_connecting_line.create_line(dot.center_position, dot.center_position, dot.color)

func _on_input_released(mouse_pos):
	_connecting_line.clear_line()
	if _connected_dots.size() > 1:
		var last_dot = _connected_dots.back()
		if Dots.get_dot_count_between_dots(_connected_dots, last_dot, last_dot) > \
				Dots._DOTS_SPECIAL_LOOP_MIN_COUNT - 1:
					emit_signal("dots_connected_removed", _connected_dots)
					var color_id_to_remove = last_dot.color_id
					_connected_dots.clear()
					for dot in _dots:
						if dot && dot.color_id == color_id_to_remove:
							_connected_dots.append(dot)
		else:
			emit_signal("dots_connected_removed", _connected_dots)
		_accept_and_remove_connected_dots()
	
	for dot in _dots:
		if dot:
			_prepare_board_after_dots_removal()
			_connected_dots.clear()
			return

	_connected_dots.clear()
	_clear_dots_array()
	emit_signal("all_dots_removed")

func _on_input_dragged(mouse_pos):
	if _connected_dots.size() > 0:
		var dot = _get_dot_under_cursor(mouse_pos)
		var last_connected_dot = _connected_dots.back()
		if dot:
			if _can_disconnect_dots(last_connected_dot, dot):
				_connected_dots.remove(_connected_dots.rfind(last_connected_dot))
				emit_signal("dot_disconnected", dot)
				_connecting_line.remove_last_point()
			elif _can_connect_new_dot(last_connected_dot, dot) && \
					!Dots.is_loop_exists(_connected_dots):
				_connected_dots.append(dot)
				emit_signal("dot_connected", dot)
				_connecting_line.set_line_end(dot.center_position)
				_connecting_line.add_point(mouse_pos)
				if Dots.is_loop_exists(_connected_dots):
					_connecting_line.set_line_end(dot.center_position)
					if Dots.get_dot_count_between_dots(_connected_dots, dot, dot) \
							> Dots._DOTS_SPECIAL_LOOP_MIN_COUNT - 1:
						var dots_one_color : Array
						for d in _dots:
							if d && d.color_id == dot.color_id:
								dots_one_color.append(d)
						var dots_loop : Array
						var dot_begin_idx = _connected_dots.find(dot)
						var dot_end_idx = _connected_dots.rfind(dot)
						for idx in range(dot_begin_idx, dot_end_idx):
							dots_loop.append(_connected_dots[idx])
						emit_signal("dots_looped", dots_loop)
						emit_signal("dots_selected", dots_one_color)
		if !Dots.is_loop_exists(_connected_dots):
			_connecting_line.set_line_end(mouse_pos)

func _get_dot_under_cursor(mouse_pos : Vector2):
	for dot in _dots:
		if dot && dot.is_contains_mouse(mouse_pos):
			return dot
	return null

func _accept_and_remove_connected_dots():
	var column_count = _dots_positions[_current_step_idx].columns
	var removed_ids : Array
	for connected_dot in _connected_dots:
		var idx = _get_idx(column_count, connected_dot.row, connected_dot.column)
		if removed_ids.find(idx) != -1:
			continue
		removed_ids.append(idx)
		_dots[idx] = null
	emit_signal("dots_removed", _connected_dots)
	_connected_dots.clear()

func _prepare_board_after_dots_removal():
	var column_count = _dots_positions[_current_step_idx].columns
	var row_count = _dots_positions[_current_step_idx].get_child_count() / column_count
	
	var existing_dots_to_move : Array
	for c in column_count:
		var cur_row_dots : Array
		var nulls_count = 0
		for r in row_count:
			cur_row_dots.append(_dots[_get_idx(column_count, r, c)])
			if !_dots[_get_idx(column_count, r, c)]:
				nulls_count += 1
		
		if nulls_count > 0:
			cur_row_dots.sort_custom(Dots, "sort_by_null_ascending")
			for r in range(row_count - 1, 0, -1):
				if !cur_row_dots[r]:
					break
				if cur_row_dots[r].row != r:
					existing_dots_to_move.append(cur_row_dots[r])
					cur_row_dots[r].initialize(r, c, cur_row_dots[r].color_id, \
							cur_row_dots[r].colorblind_sprite)
		
		for n in nulls_count:
			for r in range(row_count - 1, 0, -1):
				if !_dots[_get_idx(column_count, r, c)]:
					_dots[_get_idx(column_count, r, c)] = _dots[_get_idx(column_count, r - 1, c)]
					_dots[_get_idx(column_count, r - 1, c)] = null
	
	emit_signal("dots_moved", existing_dots_to_move, [])

func _clear_dots_array():
	_dots.clear()

func _spawn_dots(dots_positions_parent : GridContainer, colors : Array):
	if _current_step_idx > 0:
		_control_node.disconnect("resized", self, \
				"_set_dots_positions_according_to_ui")
	_clear_dots_array()
	var ui_positions = dots_positions_parent.get_children()
	var column_count = dots_positions_parent.columns
	for idx in ui_positions.size():
		if colors[idx] == null:
			_dots.append(null)
			continue
		var dot = _dot_packed_scene.instance()
		add_child(dot)
		var color = _colors_resource.get_color(colors[idx])
		var colorblind_texture = \
			_colorblind_mode.get_texture(colors[idx])
		dot.initialize(_get_row(column_count, idx), \
				_get_column(column_count, idx), \
				color, colorblind_texture)
		_dots.append(dot)
	
	_control_node.connect("resized", self, \
			"_set_dots_positions_according_to_ui", \
			[_dots, ui_positions], CONNECT_DEFERRED)
	
	_set_dots_positions_according_to_ui(_dots, ui_positions)
	_show_colorblind_sprites(_colorblind_mode.is_active)

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

func _get_row(columns_count : int, idx : int):
	return idx / columns_count

func _get_column(columns_count : int, idx : int):
	return idx % columns_count

func _get_idx(columns_count : int, row : int, col : int):
	return row * columns_count + col

func _set_dots_positions_according_to_ui(dots : Array, ui_positions : Array):
	for idx in dots.size():
		if dots[idx]:
			dots[idx].global_position = ui_positions[idx].rect_global_position

func _show_colorblind_sprites(is_enabled : bool):
	for dot in _dots:
		dot.show_colorblind_sprite(is_enabled)
