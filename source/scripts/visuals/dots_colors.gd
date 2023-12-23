class_name DotsColors
extends Resource

export(Array) var _colors # Array[Array] [0] - color; [1] - sprite

var count setget , _get_count

func get_color(i : int):
	return _colors[i][0]

func get_colorblind_sprite(i : int):
	return _colors[i][1]

func get_color_idx(color : Color):
	for idx in _colors.size():
		if get_color(idx).to_html() == color.to_html():
			return idx
	return -1

func _get_count():
	return _colors.size()
