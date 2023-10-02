class_name TutorialButtonVisual
extends LabelButtonVisual

export(NodePath) var _score_path
export(NodePath) var _highscore_path
export(NodePath) var _player_prefs_path
export(NodePath) var _popup_confirm_path
export(NodePath) var _transition_color_rect_path
export(NodePath) var _scene_root_path
export(NodePath) var _theme_changer_path
export(NodePath) var _colorblind_mode_path
export(NodePath) var _sound_path
export(String, FILE, "*.tscn") var _tutorial_scene_file_path
export(String) var _tutorial_theme_changer_path
export(String) var _tutorial_colorblind_mode_path
export(String) var _tutorial_sound_path

onready var _animation_player = $AnimationPlayer
onready var _scene_root = .get_node(_scene_root_path)
onready var _score = .get_node(_score_path)
onready var _highscore = .get_node(_highscore_path)
onready var _player_prefs = .get_node(_player_prefs_path)
onready var _popup_confirm = .get_node(_popup_confirm_path)
onready var _transition_color_rect = .get_node(_transition_color_rect_path)
onready var _theme_changer = .get_node(_theme_changer_path)
onready var _colorblind_mode = .get_node(_colorblind_mode_path)
onready var _sound = .get_node(_sound_path)

func _ready():
	.connect("button_pressed", self, "_try_call_popup")

func _try_call_popup():
	_animation_player.play("wiggle")
	if _score.get_score() > 0:
		_popup_confirm.show_popup_callback("KEY_TUTORIAL_START_CONFIRMATION", \
				self, "_show_tutorial")
	else:
		get_tree().create_timer(2.0 / 6.0).connect("timeout", self, "_show_tutorial")

func _show_tutorial():
	if _score.get_score() > 0:
		_save_progress()
	
	var canvas_layer = _transition_color_rect.get_parent()
	canvas_layer.get_parent().remove_child(canvas_layer)
	get_tree().root.add_child(canvas_layer)
	
	var trans_col_rect_color = _transition_color_rect.color
	_transition_color_rect.color = \
			Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 0.0)
	_transition_color_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(_transition_color_rect, "color", \
			Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 1.0), 0.5)\
			.set_delay(0.5 if _score.get_score() > 0 else 0.0)
	tween.tween_callback(self, "_load_tutorial_scene")
	tween.tween_callback(canvas_layer, "queue_free").set_delay(0.2)

func _load_tutorial_scene():
	if ResourceLoader.exists(_tutorial_scene_file_path):
		var tutorial_scene = ResourceLoader.load(_tutorial_scene_file_path).instance()
		var root = get_tree().root
		root.add_child(tutorial_scene)
		var tut_theme_changer = tutorial_scene.get_node(_tutorial_theme_changer_path)
		tut_theme_changer.change_theme(_theme_changer._current_theme)
		var tut_colorblind_mode = tutorial_scene.get_node(_tutorial_colorblind_mode_path)
		tut_colorblind_mode.activate_mode(_colorblind_mode._is_active)
		var tut_sound = tutorial_scene.get_node(_tutorial_sound_path)
		tut_sound.load_sounds()
		tut_sound.mute(_sound.is_muted())
		root.remove_child(_scene_root)
		_scene_root.queue_free()

func _save_progress():
	var old_highscore = _highscore.get_highscore()
	_highscore.evaluate_and_set_highscore(_score.get_score())
	var new_highscore = _highscore.get_highscore()
	if old_highscore != new_highscore:
		_highscore.save_me(_player_prefs)
		print("saved!!!!!!!!!")
	print("saved")
