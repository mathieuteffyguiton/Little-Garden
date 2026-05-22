extends Node
signal settings_changed

const SETTINGS_PATH := "user://settings.json"

var settings := {
	"language": "fr",
	"master_volume": 80,
	"music_volume": 80,
	"sfx_volume": 80,
	"fullscreen": false,
	"detected_keyboard": "unknown"
}

func _ready() -> void:
	load_settings()
	apply_settings()

func set_master_volume(value: float) -> void:
	settings["master_volume"] = clampi(int(value), 0, 100)
	apply_settings()
	save_settings()
	settings_changed.emit()

func set_music_volume(value: float) -> void:
	settings["music_volume"] = clampi(int(value), 0, 100)
	save_settings()
	settings_changed.emit()

func set_sfx_volume(value: float) -> void:
	settings["sfx_volume"] = clampi(int(value), 0, 100)
	save_settings()
	settings_changed.emit()

func set_fullscreen(value: bool) -> void:
	settings["fullscreen"] = value
	apply_settings()
	save_settings()
	settings_changed.emit()

func set_language(value: String) -> void:
	settings["language"] = value
	save_settings()
	settings_changed.emit()

func set_detected_keyboard(value: String) -> void:
	settings["detected_keyboard"] = value
	save_settings()
	settings_changed.emit()

func apply_settings() -> void:
	var idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(idx, linear_to_db(max(float(settings["master_volume"]) / 100.0, 0.001)))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED)

func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings, "\t"))

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		for key in parsed.keys():
			settings[key] = parsed[key]
