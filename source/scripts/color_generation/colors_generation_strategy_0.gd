class_name ColorsGenerationStrategy0
extends ColorsGenerationStrategyBase

const _MAX_RANGE_DOT_COUNT_VALUE = 1000

var _colors_generated : int = 0

func set_counter(val : int):
	_colors_generated = val

func get_counter():
	return _colors_generated

func reset_counter():
	_colors_generated = 0

func generate_color(dots : Array, colors : DotsColors, 
		column_count : int, row : int, column : int, colors_count : int):
	_colors_generated += 1
	return regenerate_color(dots, colors, column_count, row, column, colors_count)

func regenerate_color(dots : Array, colors : DotsColors, 
		column_count : int, row : int, column : int, colors_count : int):
	var adjacent_dots = get_adjacent_dots_all(dots, column_count, row, column)
	
	var generative_colors : Array
	for i in min(colors_count, colors.count):
		generative_colors.append(colors.get_color(i).to_html())
	
	var max_weight = 100
	var colors_html_weights : Array
	for col in generative_colors:
		colors_html_weights.append(max_weight)
	
	var adjacent_colors_weight_mult = \
			_convert_to_range(\
			clamp(_colors_generated, 0, _MAX_RANGE_DOT_COUNT_VALUE), \
			0, _MAX_RANGE_DOT_COUNT_VALUE, \
			1.0, 0.3)
#	print("%.2f" % adjacent_colors_weight_mult)
	
	var adjacent_colors_html_unique : Array
	for dot in adjacent_dots:
		var color_html = dot.color.to_html()
		var color_html_unique_idx = adjacent_colors_html_unique.find(color_html)
		var gen_color_idx = generative_colors.find(color_html)
		colors_html_weights[gen_color_idx] = \
				int(colors_html_weights[gen_color_idx] * adjacent_colors_weight_mult)
#		colors_html_weights[gen_color_idx] = int(colors_html_weights[gen_color_idx])
		if color_html_unique_idx == -1:
			adjacent_colors_html_unique.append(color_html)
	
	var colors_counts_on_board : Array
	for color_html in generative_colors:
		colors_counts_on_board.append([color_html, _get_color_count(dots, color_html)])
	colors_counts_on_board.sort_custom(self, "_sort_by_color_count")
	for i in colors_counts_on_board.size():
		var pair = colors_counts_on_board[i - 1]
		var color_html = pair[0]
		var count = pair[1]
		var idx = generative_colors.find(color_html)
		var count_percent = count / float(dots.size())
		var count_weight = int(max_weight * count_percent)
		colors_html_weights[idx] = max(1, colors_html_weights[idx] - count_weight)
	
#	var s = ""
#	for w in colors_html_weights:
#		s = "%s %d" % [s, w]
	
	var weights_sum = 0
	for w in colors_html_weights:
		weights_sum += w
	var rand_weight = randi() % weights_sum
	
	for idx in colors_html_weights.size():
		rand_weight -= colors_html_weights[idx]
		if rand_weight < 0:
#			print("%d: %s -> %d" % [colors_count, s, colors_html_weights[idx]])
			return Color(generative_colors[idx])
	
#	print("random")
	return Color(generative_colors[randi() % generative_colors.size()])

func get_adjacent_dots_all(dots : Array, column_count : int, \
		row : int, column : int):
	var left_dot = ._get_dot(dots, column_count, row, column - 1)
	var right_dot = ._get_dot(dots, column_count, row, column + 1)
	var top_dot = ._get_dot(dots, column_count, row - 1, column)
	var bottom_dot = ._get_dot(dots, column_count, row + 1, column)
	var top_left_dot = ._get_dot(dots, column_count, row - 1, column - 1)
	var top_right_dot = ._get_dot(dots, column_count, row - 1, column + 1)
	var bottom_left_dot = ._get_dot(dots, column_count, row + 1, column - 1)
	var bottom_right_dot = ._get_dot(dots, column_count, row + 1, column + 1)
	
	var adjacent_dots = [
		top_left_dot,
		left_dot,
		bottom_left_dot,
		bottom_dot,
		bottom_right_dot,
		right_dot,
		top_right_dot,
		top_dot
	]
	
	for idx in range(adjacent_dots.size(), 0, -1):
		if !adjacent_dots[idx - 1]:
			adjacent_dots.remove(idx - 1)
	
	return adjacent_dots

func get_adjacent_dots_right_bottom(dots : Array, column_count : int, \
		row : int, column : int):
	var right_dot = ._get_dot(dots, column_count, row, column + 1)
	var bottom_dot = ._get_dot(dots, column_count, row + 1, column)
	var bottom_right_dot = ._get_dot(dots, column_count, row + 1, column + 1)
	
	var adjacent_dots = [
		bottom_dot,
		bottom_right_dot,
		right_dot
	]
	
	for idx in range(adjacent_dots.size(), 0, -1):
		if !adjacent_dots[idx - 1]:
			adjacent_dots.remove(idx - 1)
	
	return adjacent_dots

func _get_color_count(dots : Array, color_html : String):
	var count = 0
	for dot in dots:
		if dot && dot.color.to_html() == color_html:
			count += 1
	return count

func _sort_by_color_count(a, b):
	return a[1] < b[1]

func _convert_to_range(value : float, from_min : float, from_max : float,\
		to_min : float, to_max : float):
	var from_range = from_max - from_min
	var to_range = to_max - to_min
	return (value - from_min) * to_range / from_range + to_min
