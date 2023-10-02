class_name ConnectingLine
extends Node

onready var _line = $Line

func create_line(point0 : Vector2, point1 : Vector2, color : Color):
	_line.default_color = color
	add_point(point0)
	add_point(point1)

func add_point(point : Vector2):
	_line.add_point(point)

func set_line_end(point : Vector2):
	_line.points[_line.points.size() - 1] = point

func remove_last_point():
	_line.remove_point(_line.points.size() - 1)

func clear_line():
	while _line.points.size() > 0:
		_line.remove_point(0)

func is_line_exists(point0 : Vector2, point1 : Vector2):
	for i in _line.get_point_count() - 1:
		if _line.points[i] == point0 && _line.points[i + 1] == point1 || \
				_line.points[i] == point1 && _line.points[i + 1] == point0:
			return true
	return false
