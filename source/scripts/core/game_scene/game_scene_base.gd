class_name GameSceneBase
extends GameplaySceneBase

const _MORE_MOVES_GRANTED_PREF = "more_moves_granted"

onready var _gameplay = $Gameplay
onready var _restart_label_button = $UI/MenuVisual/Menu/Options/RestartLabelButton
onready var _tutorial_label_button = $UI/MenuVisual/Menu/Options/TutorialLabelButton
onready var _menu_label_button = $UI/MenuLabelButton
onready var _moves = $UI/HeaderMoves
onready var _score = $UI/ScoresContainer/ScoreContainer
onready var _highscore = $UI/ScoresContainer/HighscoreContainer
onready var _popup_confirm = $UI/PopupConfirm
onready var _popup_endgame = $UI/PopupEndGame

func _ready():
	_theme_nodes_collection._backgrounds.append(TransitionAutoload._color_rect)
	
	_buttons = [
		$UI/MenuLabelButton,
		$UI/MenuVisual/Menu/Options/RestartLabelButton,
		$UI/MenuVisual/Menu/Options/TutorialLabelButton,
		$UI/MenuVisual/Menu/Options/ColorblindLabelButton,
		$UI/MenuVisual/Menu/Options/ThemeLabelButton,
		$UI/MenuVisual/Menu/Options/AudioLabelButton
	]
	
	_saveables.append_array([
		_highscore
	])

func save_progress():
	_highscore.evaluate_and_set_highscore(_score.get_score())
	.save_progress()

func _on_ready():
	_audio.connect("muted", self, "_save_audio_prefs")
	ThemeChangerAutoload.connect("theme_changed", self, "_save_theme_prefs")
	_colorblind_mode.connect("colorblind_changed", self, "_save_colorblind_prefs")
	
	_connect_game_input()
	_gameplay.connect_game_input(_game_input)
	
	_moves.connect("no_moves_left", self, "_on_finish_game")
	_gameplay.connect("dots_removed_no_args", self, "_save_gameplay_to_disk", \
			[], CONNECT_DEFERRED)
	
	_init_ui()
	
	._on_ready()
	load_progress()
	
	if _gameplay.can_be_loaded(PlayerPrefsAutoload):
		_gameplay.load_me(PlayerPrefsAutoload)
		_moves.load_me(PlayerPrefsAutoload)
		_score.load_me(PlayerPrefsAutoload)
		_popup_endgame.set_watch_button_enabled(\
				!PlayerPrefsAutoload.get_pref(_MORE_MOVES_GRANTED_PREF, false))
	else:
		_start_new_game()

func _init_moves():
	_gameplay.connect("dot_connected_no_args", _moves, \
			"set_additional_moves", [-1])
	_gameplay.connect("dot_connected_no_args", _moves, \
			"show_add_moves_label", [true])
	_gameplay.connect("dot_disconnected_no_args", _moves, \
			"set_additional_moves", [-1])
	_gameplay.connect("dots_connected_loop", self, "_set_additional_moves_minus_one")
	_gameplay.connect("dots_removed_no_args", _moves, "add_moves", [-1])
	_gameplay.connect("dots_removed_loop", _moves, "add_moves")
	_moves.reset_moves()

func _init_score():
	_gameplay.connect("dot_connected_no_args", _score, \
			"show_add_score_label", [true])
	_gameplay.connect("dots_connected", _score, "set_additional_score")
	_gameplay.connect("dots_selected_one_color", _score, "set_additional_score")
	_gameplay.connect("dots_removed", self, "_add_score")
	_gameplay.connect("dots_removed_no_args", self, "_update_colors_count")
	_score.reset_score()

func _init_ui():
	_menu_label_button.set_menu_visible_no_effects(false)
	_menu_label_button.connect("menu_opened", _game_input, "enable_input", \
			[false])
	_menu_label_button.connect("menu_closed", _game_input, "enable_input", \
			[true])
	
	_restart_label_button.connect("pressed", self, "_show_confirmation_before_restart")
	_tutorial_label_button.connect("pressed", self, "_show_confirmation_before_tutorial")
	_popup_endgame.set_new_game_button_callback(self, "_restart_game")
	_popup_endgame.set_new_game_button_callback(_popup_endgame, "hide_popup")
	_set_popup_endgame_watch_ad_callbacks()
	_popup_endgame.connect("popup_shown", _game_input, "enable_input", [false])
	_popup_endgame.connect("popup_hidden", _game_input, "enable_input", [true])
	
	_init_moves()
	_init_score()

func _set_popup_endgame_watch_ad_callbacks():
	_popup_endgame.set_watch_ad_button_callback(_moves, "add_moves", [10])
	_popup_endgame.set_watch_ad_button_callback(_popup_endgame, "hide_popup")
	_popup_endgame.set_watch_ad_button_callback(_popup_endgame, \
			"set_watch_button_enabled", [false])
	_popup_endgame.set_watch_ad_button_callback(self, \
			"_save_gameplay_to_disk", [], CONNECT_DEFERRED)
	_popup_endgame.set_watch_ad_button_callback(self, \
			"_save_more_moves_granted", [true])

func _on_input_just_released(mouse_pos):
	_moves.show_add_moves_label(false)
	_score.show_add_score_label(false)

func _save_gameplay_to_disk():
	_gameplay.save_me(PlayerPrefsAutoload)
	_moves.save_me(PlayerPrefsAutoload)
	_score.save_me(PlayerPrefsAutoload)
	PlayerPrefsAutoload.save_data()

func _clear_gameplay_from_disk():
	_gameplay.clear_saved_data(PlayerPrefsAutoload)
	_moves.clear_saved_data(PlayerPrefsAutoload)
	_score.clear_saved_data(PlayerPrefsAutoload)
	_clear_more_moves_granted()
#	PlayerPrefsAutoload.save_data()

func _save_more_moves_granted(is_granted : bool):
	PlayerPrefsAutoload.set_pref(_MORE_MOVES_GRANTED_PREF, is_granted)
	PlayerPrefsAutoload.save_data()

func _clear_more_moves_granted():
	PlayerPrefsAutoload.remove_pref(_MORE_MOVES_GRANTED_PREF)

func _add_score(count : int):
	_score.set_score(_score.get_score() + count)

func _show_confirmation_before_restart():
	if _score.get_score() > 0:
		_popup_confirm.show_popup_callback("KEY_RESTART_CONFIRMATION",\
				self, "_restart_game_close_menu")
	else:
		_restart_game_close_menu()

func _show_confirmation_before_tutorial():
	if _score.get_score() > 0:
		_popup_confirm.show_popup_callback("KEY_TUTORIAL_START_CONFIRMATION",\
				self, "_show_tutorial")
	else:
		_show_tutorial()

func _start_new_game():
	_clear_gameplay_from_disk()
	get_tree().create_timer(1.0).connect("timeout", \
			_popup_endgame, "set_watch_button_enabled", [true])
	_gameplay.start_new_game(_score.get_color_count())

func _restart_game():
	_clear_gameplay_from_disk()
	save_progress_to_disk()
	
	_score.reset_score()
	_moves.reset_moves()
	
	_start_new_game()

func _restart_game_close_menu():
	_restart_game()
	_menu_label_button.close_menu()

func _show_tutorial():
	_clear_gameplay_from_disk()
	save_progress_to_disk()
	_tutorial_label_button._change_scene()

func _on_finish_game():
	var is_highscore = _score.get_score() > _highscore.get_highscore()
	_popup_endgame.set_score_label(_score.get_score(), is_highscore)
	if is_highscore:
		PlayerPrefsAutoload.set_pref(_highscore._HIGHSCORE_PREF, _score.get_score())
	_clear_gameplay_from_disk()
#	PlayerPrefsAutoload.save_data()
	TransitionAutoload.show_screen(0.0, 1.0)
	get_tree().create_timer(0.5).connect("timeout", _popup_endgame, "show_popup")

func _update_colors_count():
	_gameplay.update_colors_count(_score.get_color_count())

func _set_colorblind_mode(is_enabled : bool):
	_gameplay.show_colorblind_sprites(is_enabled)

func _connect_game_input():
	_game_input.connect("input_enabled", _gameplay, "connect_game_input", \
			[_game_input])
	_game_input.connect("input_disabled", _gameplay, "disconnect_game_input", \
			[_game_input])
	_game_input.connect("input_just_released", self, "_on_input_just_released")

func _set_additional_moves_minus_one(count : int):
	_moves.set_additional_moves(count - 1)

func _disconnect_game_input():
	_game_input.disconnect("input_enabled", _gameplay, "connect_game_input")
	_game_input.disconnect("input_disabled", _gameplay, "disconnect_game_input")
	_game_input.disconnect("input_just_released", self, \
			"_on_input_just_released")

func _connect_audio():
	_gameplay.connect_audio(_audio)
	_moves.connect("no_moves_left", _audio, "play_sound", ["end_game"])

func _disconnect_audio():
	_gameplay.disconnect_audio(_audio)
	if _moves.is_connected("no_moves_left", _audio, "play_sound"):
		_moves.disconnect("no_moves_left", _audio, "play_sound")

func _save_audio_prefs(is_muted):
	_audio.save_me(PlayerPrefsAutoload)
	PlayerPrefsAutoload.save_data()

func _save_theme_prefs(is_muted):
	ThemeChangerAutoload.save_me(PlayerPrefsAutoload)
	PlayerPrefsAutoload.save_data()

func _save_colorblind_prefs(is_muted):
	_colorblind_mode.save_me(PlayerPrefsAutoload)
	PlayerPrefsAutoload.save_data()
