class_name TutorialDots
extends Dots

signal all_dots_removed
signal dots_regenerated(dots)

export(Array) var _color_ids

func generate_new_tutorial():
	var is_regeneration = _dots && _dots.size() != 0
	for idx in _dots.size():
		var dot = _dots[idx]
		if dot == null:
			continue
		_dots[idx] = null
		dot.queue_free()
	_dots.clear()
	
	.generate_new(4)
	if is_regeneration:
		emit_signal("dots_regenerated", _dots)

func try_remove_connected_dots():
	.try_remove_connected_dots()
	
	for dot in _dots:
		if dot:
			return
	emit_signal("all_dots_removed")

func get_dot_at_position(pos : Vector2):
	for dot in _dots:
		if dot && dot.is_contains_mouse(pos):
			return dot
	return null

func _generate_dot_in_empty_position(idx : int, is_regenerate : bool):
	var row = _get_row(idx)
	var column = _get_column(idx)
	var color = _colors.get_color(_color_ids[_get_idx(row, column)])
	var colorblind_texture = \
			_colors.get_colorblind_sprite(_colors.get_color_idx(color))
	var dot = _instantiate_dot(row, column, color, colorblind_texture)
	return dot

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
	
	emit_signal("dots_moved", _columns_count, \
			existing_dots_to_move, existing_dots_target_positions, \
			[], [])

func _update_dots_positions():
	for i in _dots.size():
		if _dots[i]:
			_dots[i].global_position = \
					_dots_positions_parent.get_child(i).rect_global_position
