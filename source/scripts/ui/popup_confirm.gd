class_name PopupConfirm
extends PopupWithBackground

var _last_target_accept_button_callback : Object
var _last_accept_button_callback : String

onready var _label = $PopupDialog/VBoxContainer/Label
onready var _accept_button = $PopupDialog/VBoxContainer/VBoxContainer/AcceptButton
onready var _cancel_button = $PopupDialog/VBoxContainer/VBoxContainer/CancelButton

func _ready():
	_popup.connect("popup_hide", self, "_disconnect_last_target_accept_button", \
			[], CONNECT_DEFERRED)
	
	_accept_button.connect("pressed", self, "hide_popup")
	_cancel_button.connect("pressed", self, "hide_popup")

func show_popup_callback(text : String, \
		target_accept_callback : Object, accept_callback : String):
	_disconnect_last_target_accept_button()
	
	_label.text = text
	_accept_button.connect("pressed", target_accept_callback, accept_callback)
	
	_last_target_accept_button_callback = target_accept_callback
	_last_accept_button_callback = accept_callback
	
	.show_popup()

func _disconnect_last_target_accept_button():
	if _last_target_accept_button_callback:
		_accept_button.disconnect("pressed", \
				_last_target_accept_button_callback, \
				_last_accept_button_callback)
	
	_last_target_accept_button_callback = null
	_last_accept_button_callback = ""
