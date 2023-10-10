class_name RestartLabelButton
extends AnimatedLabelButton

#export(NodePath) var _animation_player_path
#export(NodePath) var _settings_path
#export(NodePath) var _settings_button_visual_path
#export(NodePath) var _moves_path
#export(NodePath) var _score_path
#export(NodePath) var _highscore_path
#export(NodePath) var _popup_confirm_path
#
#onready var _animation_player = .get_node(_animation_player_path)
#onready var _settings = .get_node(_settings_path)
#onready var _dots = _settings._dots
#onready var _settings_button_visual = .get_node(_settings_button_visual_path)
#onready var _moves = .get_node(_moves_path)
#onready var _score = .get_node(_score_path)
#onready var _highscore = .get_node(_highscore_path)
#onready var _popup_confirm = .get_node(_popup_confirm_path)
#
#func _ready():
#	var delay = _animation_player.get_animation("rotate_icon").length
#	.connect("button_pressed", self, "_show_popup_after_delay", [delay * 0.4])
#
#func _show_popup_after_delay(delay : float):
#	_animation_player.play("rotate_icon")
#
#	if _score.get_score() > 0:
#		var tween = .get_tree().create_tween()
#		tween.tween_callback(_popup_confirm, "show_popup_callback", \
#				["KEY_RESTART_CONFIRMATION", self, "_restart"])\
#				.set_delay(delay)
#	else:
#		var tween = .get_tree().create_tween()
#		tween.tween_callback(self, "_restart").set_delay(delay)
#
#func _restart():
#	var old_score = _score.get_score()
#	_dots.generate_new()
#	_moves.reset_moves()
#	_highscore.evaluate_and_set_highscore(_score.get_score())
#	_score.reset_score()
#	get_tree().create_timer(0.4 if old_score > 0 else 0.0).connect("timeout", \
#			_settings_button_visual._settings_button, "emit_signal", ["pressed"])
#
