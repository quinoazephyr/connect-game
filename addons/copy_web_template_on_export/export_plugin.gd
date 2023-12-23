tool
extends EditorExportPlugin

const CUSTOM_HTML_SHELL_PATH = \
		"res://export/yandex_template/yandex_template.html"

var _exporting = false
var _export_path = ""

func _export_begin(features: PoolStringArray, is_debug: bool, path: String, flags: int) -> void:
	if features.has("web"):
		_exporting = true
		_export_path = path

func _export_end() -> void:
	if _exporting:
		var template_dir = CUSTOM_HTML_SHELL_PATH.get_base_dir()
		_copy_files(template_dir, _export_path.get_base_dir())
	_exporting = false

func _copy_files(origin_path, target_path):
	var dir = Directory.new()
	if dir.open(origin_path) == OK:
		dir.list_dir_begin(true, true)
		var filename = dir.get_next()
		while filename != "":
			var origin_filename = origin_path + '/' + filename
			var target_filename = target_path + '/' + filename
			if dir.current_is_dir():
				Directory.new().make_dir(target_filename)
				_copy_files(origin_filename, target_filename)
			elif filename.get_file() != CUSTOM_HTML_SHELL_PATH.get_file():
				Directory.new().copy(origin_filename, target_filename)
			filename = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path: " + origin_path)
