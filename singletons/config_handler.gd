## A singleton that manages config file saving and loading.
##
## This singleton is based on DashNothing's tutorial video about saving and
## loading settings using the [ConfigFile] class.
##
## @tutorial(Saving and Loading Settings): https://www.youtube.com/watch?v=tfqJjDw0o7Y
extends Node

## File path for the config file.
const _SETTINGS_FILE_PATH := "user://settings.ini"

## [ConfigFile] to save to and load from.
var _config := ConfigFile.new()


func _ready() -> void:
	if not FileAccess.file_exists(_SETTINGS_FILE_PATH):
		_config.set_value("video", "fullscreen", false)
		_config.set_value("video", "borderless", false)
		
		_config.set_value("audio", "master_volume", 1.0)
		_config.set_value("audio", "music_volume", 1.0)
		_config.set_value("audio", "sfx_volume", 0.6)
		
		_config.set_value("gameplay", "letter_tile_separation", 40)
		_config.set_value("gameplay", "connector_thickness", 8)
		_config.set_value("gameplay", "distinct_multiplier_tiles", false)
		_config.set_value("gameplay", "wordlist_path",
				"res://assets/wordlists/letterpress.txt")
		
		_config.set_value("freeplay", "min_word_length", 2)
		_config.set_value("freeplay", "letter_distribution",
				load("res://gameplay/letter_distributions/variety1.tres"))
		_config.set_value("freeplay", "game_mode", "Sprint")
		_config.set_value("freeplay", "sprint_time", 120)
		_config.set_value("freeplay", "percent_to_find", 50)
		_config.set_value("freeplay", "grid_layout",
				load("res://gameplay/grid_layouts/classic.tres"))
		
		_config.save(_SETTINGS_FILE_PATH)
	else:
		_config.load(_SETTINGS_FILE_PATH)
	
	var video_settings := load_settings("video")
	set_fullscreen(video_settings.fullscreen)
	set_borderless_window(video_settings.borderless)
	
	var audio_settings := load_settings("audio")
	set_volume("Master", audio_settings.master_volume)
	set_volume("Music", audio_settings.music_volume)
	set_volume("SFX", audio_settings.sfx_volume)


## Saves the [param key] and [param value] pair to the config file under the
## section [param section_name].
func save_settings(section_name: String, key: String, value: Variant) -> void:
	_config.set_value(section_name, key, value)
	_config.save(_SETTINGS_FILE_PATH)


## Returns settings from the config file under the section [param section_name].
func load_settings(section_name: String) -> Dictionary:
	var section_settings: Dictionary = {}
	for key in _config.get_section_keys(section_name):
		section_settings[key] = _config.get_value(section_name, key)
	return section_settings


## If [code]true[/code], the game window is set to fullscreen.
func set_fullscreen(is_fullscreen: bool) -> void:
	if is_fullscreen:
		DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


## If [code]true[/code], the game window is set to borderless.
func set_borderless_window(is_borderless: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,
			is_borderless)


## Sets the volume of the audio bus named [param bus_name] to a
## [param linear_energy] ranging from 0 to 1.
func set_volume(bus_name: String, linear_energy: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var decibels := linear_to_db(linear_energy)
	AudioServer.set_bus_volume_db(bus_index, decibels)
