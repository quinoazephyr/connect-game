class_name StartSceneBase
extends Node

onready var _language_changer = $LanguageChanger
onready var _theme_nodes_collection = $ThemeNodesCollection

func _ready():
	_language_changer.set_system_language()
	
	_theme_nodes_collection._backgrounds.append(TransitionAutoload._color_rect)
	
	connect("ready", self, "_set_initial_theme")

func _set_initial_theme():
	ThemeChangerAutoload.change_theme_by_name(_get_initial_theme_name())

func _get_initial_theme_name():
	return "Light"
