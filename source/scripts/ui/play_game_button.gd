class_name PlayGameButton
extends Button

export(NodePath) var _transition_color_rect_path
export(NodePath) var _scene_root_path
export(NodePath) var _theme_changer_path
export(String, FILE, "*.tscn") var _main_scene_file_path
export(String) var _main_scene_game_yandex_path
export(String) var _main_scene_theme_changer_path

onready var _transition_color_rect = get_node(_transition_color_rect_path)
onready var _scene_root = get_node(_scene_root_path)
onready var _theme_changer = get_node(_theme_changer_path)

func _ready():
	connect("pressed", self, "_show_main_scene_transition")
	
	if OS.has_feature("HTML5"):
		var window = JavaScript.get_interface("window")
		if window.isDarkMode():
			_theme_changer.change_theme(ThemeChanger.Themes.DARK_THEME)
		else:
			_theme_changer.change_theme(ThemeChanger.Themes.LIGHT_THEME)
	else:
		_theme_changer.change_theme(ThemeChanger.Themes.LIGHT_THEME)

func _show_main_scene():
	if ResourceLoader.exists(_main_scene_file_path):
		var main_scene = ResourceLoader.load(_main_scene_file_path).instance()
		
		var root = get_tree().root
		root.add_child(main_scene)
		root.remove_child(_scene_root)
		var main_scene_theme_changer = \
				main_scene.get_node(_main_scene_theme_changer_path)
		main_scene_theme_changer.change_theme(_theme_changer._current_theme)
		var _main_scene_game_yandex = \
				main_scene.get_node(_main_scene_game_yandex_path)
		_main_scene_game_yandex.initialize(root.get_node("/root/YandexSdkWrapper"))
		_scene_root.queue_free()

func _show_main_scene_transition():
	var app_root = get_tree().root
	var canvas_layer = _transition_color_rect.get_parent()
	canvas_layer.get_parent().remove_child(canvas_layer)
	app_root.add_child(canvas_layer)
	
	_transition_color_rect.visible = true
	var trans_col_rect_color = _transition_color_rect.self_modulate
	var transition_time = 0.5
	var tween = get_tree().create_tween()
	tween.tween_property(_transition_color_rect, "self_modulate", \
			Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 1.0), transition_time)\
			.from(Color(trans_col_rect_color.r, trans_col_rect_color.g, \
			trans_col_rect_color.b, 0.0))
	tween.tween_callback(self, "_show_main_scene")
	tween.tween_callback(canvas_layer, "queue_free").set_delay(0.2)
