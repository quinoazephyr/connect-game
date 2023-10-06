class_name StartSceneWebGL
extends StartSceneBase

func _get_initial_theme_name():
	var window = JavaScript.get_interface("window")
	if window.isDarkMode():
		return "Dark"
	else:
		return "Light"
