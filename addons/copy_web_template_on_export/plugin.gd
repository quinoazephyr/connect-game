tool
extends EditorPlugin

var _export_plugin: EditorExportPlugin = null

func _enter_tree():
	_export_plugin = \
			load("res://addons/copy_web_template_on_export/export_plugin.gd").new()
	add_export_plugin(_export_plugin)

func _exit_tree():
	remove_export_plugin(_export_plugin)
	_export_plugin = null
