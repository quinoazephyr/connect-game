class_name TutorialSceneBase
extends GameplaySceneBase

onready var _tutorial = $Tutorial
onready var _moves = $UI/HeaderMoves
onready var _gameplays = [
	$Tutorial/HorizontalConnectionGameplay,
	$Tutorial/VerticalConnectionsGameplay,
	$Tutorial/DiagonalConnectionsGameplay,
	$Tutorial/SquareConnectionsGameplay
]

func _ready():
	_buttons = [
		$SkipButtonLayer/SkipTutorialButton
	]

func init_gameplay(gameplay_node_path : String):
	var gameplay = get_node(gameplay_node_path)
	gameplay.connect_game_input(_game_input)
	gameplay.start_new_game(0)

func terminate_gameplay(gameplay_node_path : String):
	var gameplay = get_node(gameplay_node_path)
	gameplay.disconnect_game_input(_game_input)

func play_sound(sound_name : String):
	if _audio.is_muted:
		return
	_audio.play_sound(sound_name)

func _on_ready():
	._on_ready()
	_connect_game_input()
	load_progress()
	_tutorial.start_quest(1)

func _set_additional_moves_minus_one(count : int):
	_moves.set_additional_moves(count - 1)

func _hide_additional_moves(mouse_pos):
	_moves.show_add_moves_label(false)

func _connect_game_input():
	_game_input.connect("input_just_released", self, "_hide_additional_moves")

func _disconnect_game_input():
	_game_input.disconnect("input_just_released", self, "_hide_additional_moves")

func _set_colorblind_mode(is_enabled : bool):
	for gameplay in _gameplays:
		gameplay.show_colorblind_sprites(is_enabled)

func _connect_audio():
	for gameplay in _gameplays:
		gameplay.connect_audio(_audio)

func _disconnect_audio():
	for gameplay in _gameplays:
		gameplay.disconnect_audio(_audio)
