class_name GameSceneBase
extends SceneBase

onready var _menu_label_button = $UI/MenuLabelButton

func _ready():
	_theme_nodes_collection._backgrounds.append(TransitionAutoload._color_rect)
	
	_buttons = [
		$UI/MenuLabelButton,
		$UI/MenuVisual/Menu/Options/RestartLabelButton,
		$UI/MenuVisual/Menu/Options/TutorialLabelButton,
		$UI/MenuVisual/Menu/Options/ColorblindLabelButton,
		$UI/MenuVisual/Menu/Options/ThemeLabelButton,
		$UI/MenuVisual/Menu/Options/AudioLabelButton
	]
	
	_menu_label_button.set_menu_visible_no_effects(false)
