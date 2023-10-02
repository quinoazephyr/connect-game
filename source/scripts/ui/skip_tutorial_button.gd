class_name SkipTutorialButton
extends Button

export(NodePath) var _transition_color_rect_path
export(NodePath) var _scene_root_path
export(NodePath) var _theme_changer_path
export(NodePath) var _colorblind_mode_path
export(NodePath) var _sound_path
export(String, FILE, "*.tscn") var _main_scene_file_path
export(String) var _main_scene_theme_changer_path
export(String) var _main_scene_settings_path

onready var _scene_root = get_node(_scene_root_path)
onready var _transition_color_rect = get_node(_transition_color_rect_path)
onready var _theme_changer = get_node(_theme_changer_path)
onready var _colorblind_mode = get_node(_colorblind_mode_path)
onready var _sound = get_node(_sound_path)

func _ready():
	connect("pressed", self, "_show_main_scene_transition")
	call_deferred("_connect_sound_effect")

func _show_main_scene_transition():
	var app_root = get_tree().root
	var canvas_layer = _transition_color_rect.get_parent()
	canvas_layer.get_parent().remove_child(canvas_layer)
	app_root.add_child(canvas_layer)
	
	var trans_col_rect_color = _transition_color_rect.self_modulate
	var transition_time = 0.5
	var tween = get_tree().create_tween()
	tween.tween_property(_transition_color_rect, "self_modulate", \
			Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 1.0), transition_time)
	tween.tween_callback(self, "_show_main_scene")
	tween.tween_callback(canvas_layer, "queue_free").set_delay(0.2)

func _show_main_scene():
	if ResourceLoader.exists(_main_scene_file_path):
		var main_scene = ResourceLoader.load(_main_scene_file_path).instance()
		
		var root = get_tree().root
		root.add_child(main_scene)
		root.remove_child(_scene_root)
		var main_scene_theme_changer = \
				main_scene.get_node(_main_scene_theme_changer_path)
		main_scene_theme_changer.change_theme(_theme_changer._current_theme)
		var main_scene_settings = \
				main_scene.get_node(_main_scene_settings_path)
		main_scene_settings.is_initial_run = false
		main_scene_settings._sound.mute(_sound.is_muted())
		main_scene_settings._colorblind_mode.activate_mode(_colorblind_mode._is_active)
		_scene_root.queue_free()

func _connect_sound_effect():
	if !_sound.is_muted():
		connect("pressed", _sound, "_play_interface_click_sound")
