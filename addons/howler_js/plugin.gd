tool
extends EditorPlugin

var _export_plugin: EditorExportPlugin = null

func _enter_tree() -> void:
	_export_plugin = load("res://addons/howler_js/export_plugin.gd").new()
	add_export_plugin(_export_plugin)
	add_autoload_singleton(HowlerJS.SINGLETON_NAME, \
			"res://addons/howler_js/howler_js.gd")

func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	remove_autoload_singleton(HowlerJS.SINGLETON_NAME)
	_export_plugin = null
