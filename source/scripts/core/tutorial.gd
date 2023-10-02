class_name Tutorial
extends Node

export(Array) var _quests_resources

var _current_quest_id : int = -1

onready var _transition_color_rect = $CanvasLayer/Control

func _ready():
	var trans_col_rect_color = _transition_color_rect.color
	_transition_color_rect.visible = true
	_transition_color_rect.color = \
			Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 1.0)
	var transition_time = 0.5
	var tween = get_tree().create_tween()
	tween.tween_callback(self, "start_quest", [1]).set_delay(0.2)
	tween.tween_property(_transition_color_rect, "color", \
			Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 0.0), transition_time)

func start_quest(quest_id : int):
	for res in _quests_resources:
		if res.get_id() == quest_id:
			_current_quest_id = quest_id
			res.start(get_tree().root)
			return

func start_next_quest(has_transition : bool = true):
	if has_transition:
		var trans_col_rect_color = _transition_color_rect.color
		var transition_time = 0.5
		var tween = get_tree().create_tween()
		tween.tween_property(_transition_color_rect, "color", \
				Color(trans_col_rect_color.r, trans_col_rect_color.g, \
				trans_col_rect_color.b, 1.0), transition_time)
		tween.tween_callback(self, "start_quest", [_current_quest_id + 1])
		tween.tween_property(_transition_color_rect, "color", \
				Color(trans_col_rect_color.r, trans_col_rect_color.g, \
				trans_col_rect_color.b, 0.0), transition_time)
	else:
		start_quest(_current_quest_id + 1)
