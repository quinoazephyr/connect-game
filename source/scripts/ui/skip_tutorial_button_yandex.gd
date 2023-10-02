class_name SkipTutorialButtonYandex
extends SkipTutorialButton

export(String) var _main_scene_game_path

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
		var _main_scene_game = \
				main_scene.get_node(_main_scene_game_path)
		_main_scene_game.initialize(root.get_node("/root/YandexSdkWrapper"))
		_scene_root.queue_free()
