class_name StartSceneWebGL
extends StartSceneBase

func _get_initial_theme_name():
	var helpers = JavaScript.get_interface("Helpers")
	if helpers.isDarkMode():
		return "Dark"
	else:
		return "Light"
