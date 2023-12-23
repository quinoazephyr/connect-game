class_name TutorialDotEffects
extends DotEffects

func _on_dots_regenerated(dots : Array):
	var offset = Vector2(80.0, 0.0)
	var offset_duration = 0.5
	for dot in dots:
		var initial_position = dot.position
		var tween = dot.create_tween()
		tween.tween_property(dot, "position", \
				initial_position, offset_duration)\
				.from(initial_position - offset)\
				.set_trans(Tween.TRANS_ELASTIC)\
				.set_ease(Tween.EASE_OUT)
#	var color_duration = 0.4
#	var tween = _fullscreen_color_rect.create_tween()
#	var initial_color = _fullscreen_color_rect.color
#	var initial_color_transparent = Color(initial_color.r, initial_color.g, \
#			initial_color.b, 0.1)
#	var red_color = Color(1.0, 0.0, 0.0, initial_color_transparent.a)
#	tween.tween_callback(_fullscreen_color_rect, "set_visible", [true])
#	tween.tween_property(_fullscreen_color_rect, "color",\
#			red_color, color_duration * 0.5)\
#			.from(initial_color_transparent)\
#			.set_trans(Tween.TRANS_SINE)\
#			.set_ease(Tween.EASE_OUT)
#	tween.tween_property(_fullscreen_color_rect, "color",\
#			initial_color_transparent, color_duration * 0.5)\
#			.from(red_color)\
#			.set_trans(Tween.TRANS_SINE)\
#			.set_ease(Tween.EASE_IN)
#	tween.tween_callback(_fullscreen_color_rect, "set_visible", [false])
#	tween.tween_callback(_fullscreen_color_rect, \
#			"set_frame_color", [initial_color])

func _call_deferred_dots_regenerated(dots : Array):
	call_deferred("_on_dots_regenerated", dots)
