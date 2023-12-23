class_name StartSceneBase
extends SceneBase

const _IS_FIRST_SESSION_PREF = "is_first_session"

export(PackedScene) var _start_game_button
export(PackedScene) var _start_tutorial_button

var _play_button = null

onready var _play_button_container = $Control/VBoxContainer/PlayButtonContainer
onready var _language_changer = $LanguageChanger
onready var _language_changer_effects = $Control/VBoxContainer

func _ready():
	_language_changer.set_system_language()
	_language_changer.connect("language_changed", self, "_on_language_changed")
	
	_theme_nodes_collection._backgrounds.append(TransitionAutoload._color_rect)
	
	_audio.load_sounds()
	
	_buttons = [
		$Control/VBoxContainer/LanguageButton
	]

func _on_ready():
	._on_ready()
	
	_set_initial_theme()
	
	load_progress()
	
	var is_first_session = PlayerPrefsAutoload.get_pref(_IS_FIRST_SESSION_PREF, true)
	_spawn_play_button(is_first_session)
	
	if !PlayerPrefsAutoload.has_pref(ThemeChangerAutoload._THEME_PREF):
		ThemeChangerAutoload.save_me(PlayerPrefsAutoload)

func _on_language_changed(locale):
	_language_changer_effects.bounce_elements()

func _spawn_play_button(is_first_session : bool):
	_despawn_play_button()
	if is_first_session:
		_play_button = _start_tutorial_button.instance()
	else:
		_play_button = _start_game_button.instance()
	_play_button_container.add_child(_play_button)

	_language_changer_effects.add_element(_play_button.label)
	_theme_nodes_collection.add_accent_label(_play_button.label)
	_theme_nodes_collection.add_accent_texture(_play_button)

	if !_audio.is_muted:
		_disconnect_sounds_from_buttons()
	_buttons.append(_play_button)
	if !_audio.is_muted:
		_connect_sounds_to_buttons()

func _despawn_play_button():
	if !_play_button:
		return

	_language_changer_effects.remove_element(_play_button)
	_buttons.erase(_play_button)
	_play_button_container.remove_child(_play_button)
	_play_button.queue_free()
	_play_button = null

