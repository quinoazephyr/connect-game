class_name Game
extends Node

export(NodePath) var _game_input_path
export(NodePath) var _player_prefs_path
export(NodePath) var _dots_path
export(NodePath) var _moves_path
export(NodePath) var _score_path
export(NodePath) var _highscore_path
export(NodePath) var _popup_end_game_path
export(NodePath) var _sound_path
export(Array) var _all_buttons_paths

var _all_buttons : Array

onready var _transition_color_rect = $CanvasLayer/TransitionColorRect
onready var _game_input = get_node(_game_input_path)
onready var _player_prefs = get_node(_player_prefs_path)
onready var _dots = get_node(_dots_path)
onready var _moves = get_node(_moves_path)
onready var _score = get_node(_score_path)
onready var _highscore = get_node(_highscore_path)
onready var _popup_end_game = get_node(_popup_end_game_path)
onready var _sound = get_node(_sound_path)

func _ready():
	for path in _all_buttons_paths:
		var button = get_node(path)
		_all_buttons.append(button)
	_sound.connect("sound_muted", self, "_on_sound_muted")
	
	var trans_col_rect_color = _transition_color_rect.color
	_transition_color_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(_transition_color_rect, "color", \
			Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 0.0), 0.5)\
			.from(Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 1.0)).set_delay(0.2)
	tween.tween_property(_transition_color_rect, "visible", false, 0.0)
	
	_dots.connect("dot_connected", _moves, "_on_dot_connected")
	_dots.connect("dot_disconnected", _moves, "_on_dot_connected")
	_dots.connect("dots_looped", _moves, "_on_dots_looped")
	_dots.connect("dots_connected_removed", _moves, "_on_dots_removed")
	
	_game_input.connect("input_just_released", _moves, "_on_input_release")
	
	_moves.connect("no_moves_left", self, "_finish_game")
	
	_popup_end_game.call_deferred("set_new_game_button_callback", \
			self, "_on_new_game_pressed")
	_popup_end_game.call_deferred("set_watch_button_enabled", false)
	
	_moves.call_deferred("load_me", _player_prefs)
	_score.call_deferred("load_me", _player_prefs)
	_highscore.call_deferred("load_me", _player_prefs)

func _finish_game():
	if !_sound.is_muted():
		_sound._play_interface_confirm_sound()
	_highscore.save_me(_player_prefs)
	_player_prefs.save_data()
	
	var last_dot_effect_duration = 0.41
	var popup_delay = last_dot_effect_duration + 0.1
	
	var tween = get_tree().create_tween()
	tween.tween_callback(_game_input, "enable_input", [false])\
			.set_delay(last_dot_effect_duration)
	
	_popup_end_game.set_score_label(_score.get_score(), \
			_score.get_score() == _highscore.get_highscore())
	_popup_end_game.show_popup_delayed(popup_delay)

func _on_new_game_pressed():
	_highscore.evaluate_and_set_highscore(_score.get_score())
	_moves.reset_moves()
	_score.reset_score()
	_dots.current_colors_count = _score.get_color_count(_score.get_score())
	_dots.generate_new()
	_popup_end_game.hide_popup()
	
	_game_input.enable_input(true)

func _on_sound_muted(is_muted):
	for button in _all_buttons:
		if is_muted:
			button.disconnect("pressed", _sound, "_play_interface_click_sound")
		else:
			button.connect("pressed", _sound, "_play_interface_click_sound")
	
	if is_muted:
		_dots.disconnect("dot_connected", _sound, "_play_connection_effect")
		_dots.disconnect("dot_disconnected", _sound, "_play_disconnection_effect")
		_dots.disconnect("dots_removed", _sound, "_play_removed_effect")
		_dots.disconnect("dots_looped", _sound, "_play_loop_selected_effect")
	else:
		_dots.connect("dot_connected", _sound, "_play_connection_effect")
		_dots.connect("dot_disconnected", _sound, "_play_disconnection_effect")
		_dots.connect("dots_removed", _sound, "_play_removed_effect")
		_dots.connect("dots_looped", _sound, "_play_loop_selected_effect")
