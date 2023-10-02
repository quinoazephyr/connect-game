class_name DotsColors
extends Resource

export(Array) var _colors

var count setget , _get_count

func get_color(i : int):
	return _colors[i]

func get_color_idx(color : Color):
	for idx in _colors.size():
		if _colors[idx].to_html() == color.to_html():
			return idx
	return -1

func _get_count():
	return _colors.size()
