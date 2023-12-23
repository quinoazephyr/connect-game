class_name Gameplay
extends Saveable

signal dot_connected_no_args
signal dot_disconnected_no_args
signal dots_looped_no_args
signal dots_removed_no_args
signal dots_removed_special_loop_no_args

signal dots_connected(count)
signal dots_connected_loop(dot_count)
signal dots_removed(count)
signal dots_removed_loop(loop_dot_count)
signal dots_selected_one_color(count)

onready var _dots = $Dots
onready var _connecting_line = $ConnectingLine
onready var _dot_effects = $DotEffects

func _ready():
	_dots.connect("dot_connected", self, "_unbind_dot_connected_args")
	_dots.connect("dot_disconnected", self, "_unbind_dot_disconnected_args")
	_dots.connect("dots_looped", self, "_unbind_dots_looped_args")
	_dots.connect("dots_removed", self, "_unbind_dots_removed_args")
	_dots.connect("dots_removed_special_loop", \
			self, "_unbind_dots_removed_special_loop_args")
	
	_dots.connect("dot_connected", self, "_on_dots_connection_changed")
	_dots.connect("dot_disconnected", self, "_on_dots_connection_changed")
	_dots.connect("dots_looped", self, "_on_dots_special_loop_connected")
	_dots.connect("dots_removed", self, "_on_dots_removed")
	_dots.connect("dots_selected", self, "_on_dots_selected")
	
	_dots.connect("dot_connected", _dot_effects, "ripple_dot")
	_dots.connect("dots_removed", _dot_effects, "disappear_dots")
	_dots.connect("dots_selected", _dot_effects, "ripple_dots_with_color")
	_dots.connect("dots_moved", _dot_effects, "move_dots_down")
	_dots.connect("dots_removed_special_loop", \
			_dot_effects, "on_loop_dots_removed")
	_dots.connect("dot_disconnected", _dot_effects, "on_dot_disconnected")

func connect_game_input(game_input):
	game_input.connect("input_just_pressed", self, "_on_input_pressed")
	game_input.connect("input_just_released", self, "_on_input_released")
	game_input.connect("input_motion_drag", self, "_on_input_dragged")

func disconnect_game_input(game_input):
	game_input.disconnect("input_just_pressed", self, "_on_input_pressed")
	game_input.disconnect("input_just_released", self, "_on_input_released")
	game_input.disconnect("input_motion_drag", self, "_on_input_dragged")

func connect_audio(audio):
	connect("dot_connected_no_args", audio, "play_sound_random", \
			["dot_connection"])
	connect("dot_disconnected_no_args", audio, "play_sound_random", \
			["dot_disconnection"])
	connect("dots_looped_no_args", audio, "play_sound_random", \
			["dots_loop_selected"])
	connect("dots_removed_no_args", audio, "play_sound_random", \
			["dots_removed"])

func disconnect_audio(audio):
	if is_connected("dot_connected_no_args", audio, "play_sound_random"):
		disconnect("dot_connected_no_args", audio, "play_sound_random")
		disconnect("dot_disconnected_no_args", audio, "play_sound_random")
		disconnect("dots_looped_no_args", audio, "play_sound_random")
		disconnect("dots_removed_no_args", audio, "play_sound_random")

func start_new_game(color_count):
	_dots.generate_new(color_count)

func show_colorblind_sprites(is_enabled : bool):
	_dots.show_colorblind_sprites_all(is_enabled)
	if is_enabled:
		_dots.connect("dots_generated", self, \
				"_on_dots_generated_show_colorblind")
	elif _dots.is_connected("dots_generated", self, \
			"_on_dots_generated_show_colorblind"):
		_dots.disconnect("dots_generated", self, \
				"_on_dots_generated_show_colorblind")

func update_colors_count(colors_count : int):
	_dots.set_colors_count(colors_count)

func save_me(player_prefs : PlayerPrefs):
	_dots.save_me(player_prefs)

func load_me(player_prefs : PlayerPrefs):
	_dots.load_me(player_prefs)

func can_be_loaded(player_prefs : PlayerPrefs):
	return player_prefs.has_pref(_dots._DOTS_PREF) && \
			player_prefs.has_pref(_dots._COLORS_COUNT_PREF) && \
			player_prefs.has_pref(_dots._GENERATION_STRATEGY_COUNT_PREF)

func clear_saved_data(player_prefs : PlayerPrefs):
	player_prefs.remove_prefs([_dots._DOTS_PREF, _dots._COLORS_COUNT_PREF, \
			_dots._GENERATION_STRATEGY_COUNT_PREF])
#	player_prefs.remove_pref(_dots._DOTS_PREF)
#	player_prefs.remove_pref(_dots._COLORS_COUNT_PREF)
#	player_prefs.remove_pref(_dots._GENERATION_STRATEGY_COUNT_PREF)

func _on_dots_generated_show_colorblind(dots : Array):
	_dots.show_colorblind_sprites(dots, true)

func _on_input_pressed(mouse_pos):
	var dot = _dots.get_dot_at_position(mouse_pos)
	if dot:
		_dots.reset_connected_dots()
		_dots.connect_dot(dot)
		_connecting_line.create_line(dot.center_position, dot.center_position, \
				dot.color)

func _on_input_released(mouse_pos):
	_dots.try_remove_connected_dots()
	_dots.reset_connected_dots()
	_connecting_line.clear_line()

func _on_input_dragged(mouse_pos):
	if _dots.is_any_dot_connected():
		var dot = _dots.get_dot_at_position(mouse_pos)
		if dot:
			if _dots.can_disconnect_last_dot_after_current_dot(dot):
				_dots.disconnect_last_dot()
				_connecting_line.remove_last_point()
			elif _dots.can_connect_dot(dot) && !_dots.is_loop_in_connection():
				_dots.connect_dot(dot)
				_connecting_line.set_line_end(dot.center_position)
				_connecting_line.add_point(mouse_pos)
				if _dots.is_loop_in_connection():
					_connecting_line.set_line_end(dot.center_position)
					if _dots.is_loop_in_connection_special():
						_dots.notify_of_connected_special_loop(dot)
						_dots.select_all_dots_of_color(dot.color_id)
		if !_dots.is_loop_in_connection():
			_connecting_line.set_line_end(mouse_pos)

func _unbind_dot_connected_args(dot):
	emit_signal("dot_connected_no_args")

func _unbind_dot_disconnected_args(dot):
	emit_signal("dot_disconnected_no_args")

func _unbind_dots_looped_args(dots):
	emit_signal("dots_looped_no_args")

func _unbind_dots_removed_args(dots):
	emit_signal("dots_removed_no_args")

func _unbind_dots_removed_special_loop_args(dots):
	emit_signal("dots_removed_special_loop_no_args")

func _on_dots_connection_changed(dot):
	emit_signal("dots_connected", _dots.get_connected_dots_count())

func _on_dots_special_loop_connected(dots_loop):
	emit_signal("dots_connected_loop", dots_loop.size())

func _on_dots_removed(dots):
	emit_signal("dots_removed", dots.size())
	if _dots.is_loop_in_connection_special():
		var last_dot = dots.back()
		emit_signal("dots_removed_loop", \
				_dots.get_special_loop_dot_count_in_connection())

func _on_dots_selected(dots_one_color):
	emit_signal("dots_selected_one_color", dots_one_color.size())
