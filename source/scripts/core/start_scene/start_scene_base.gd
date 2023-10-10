class_name StartSceneBase
extends SceneBase

onready var _language_changer = $LanguageChanger

func _ready():
	_language_changer.set_system_language()
	
	_theme_nodes_collection._backgrounds.append(TransitionAutoload._color_rect)
	
	_audio.load_sounds()
	
	_buttons = [
		$Control/VBoxContainer/PlayButton,
		$Control/VBoxContainer/LanguageButton
	]
	
	connect("ready", self, "_set_initial_theme")
