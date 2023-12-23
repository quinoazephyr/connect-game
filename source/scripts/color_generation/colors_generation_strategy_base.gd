class_name ColorsGenerationStrategyBase

func _init():
	randomize()

func generate_color(dots : Array, colors : DotsColors, 
		column_count : int, row : int, column : int, colors_count : int):
	pass

func _are_dots_equal_and_not_null(dot1, dot2):
	return dot1 && dot2 && dot1.color_id == dot2.color_id

func _get_dot(dots : Array, columns_count : int, row : int, col : int):
	if row < 0 || col < 0:
		return null
	if row > dots.size() / columns_count - 1 || \
			col > columns_count - 1:
		return null
	var idx = row * columns_count + col
	return dots[idx]
