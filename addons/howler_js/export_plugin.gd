tool
extends EditorExportPlugin

const _JS_FILE = "howler.js"
const _JS_WRAPPER_FILE = "howler_wrapper.js"

var plugin_path: String = get_script().resource_path.get_base_dir()
var exporting := false
var export_path := ""

func _get_name() -> String:
	return "HowlerJS"

func _export_begin(features: PoolStringArray, is_debug: bool, path: String, flags: int) -> void:
	if features.has(HowlerJSWrapper.FEATURE_NAME):
		exporting = true
		export_path = path

func _export_end() -> void:
	if exporting:
		var file := File.new()
		file.open(export_path, File.READ)
		var html := file.get_as_text()
		file.close()
		var pos = html.find('</head>')
		
		html = html.insert(pos, 
				'<script src="' + _JS_FILE + '"></script>\n' +
				'<script src="' + _JS_WRAPPER_FILE + '"></script>\n')
		
		_copy_file(_JS_FILE, export_path.get_base_dir())
		_copy_file(_JS_WRAPPER_FILE, export_path.get_base_dir())
		
		file.open(export_path, File.WRITE)
		file.store_string(html)
		file.close()
	
	var convert_command = ProjectSettings.globalize_path(\
			"res://addons/howler_js/convert_assets_ogg_to_mp3.bat") + " " + \
			"\"assets\"" + " " + \
			"\"" + export_path.get_base_dir() + "\""
	OS.execute("cmd.exe", ["/C", convert_command], false)
	
	exporting = false

func _export_file(path: String, type: String, features: PoolStringArray) -> void:
	if path.begins_with(plugin_path) && \
			!path.ends_with("howler_js_wrapper.gd"):
		skip()

func _copy_file(filename : String, target_dir : String) -> void:
	Directory\
			.new()\
			.copy(plugin_path + '/' + filename, \
			target_dir + '/' + filename)
