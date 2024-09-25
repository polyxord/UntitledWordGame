extends Control


@export_file var wordlist_paths: Array[String]

@onready var fullscreen_option_button := %FullscreenOptionButton as OptionButton
@onready var borderless_option_button := %BorderlessOptionButton as OptionButton
@onready var master_volume_label := %MasterVolumeLabel as Label
@onready var master_volume_slider := %MasterVolumeSlider as HSlider
@onready var music_volume_label := %MusicVolumeLabel as Label
@onready var music_volume_slider := %MusicVolumeSlider as HSlider
@onready var sfx_volume_label := %SFXVolumeLabel as Label
@onready var sfx_volume_slider := %SFXVolumeSlider as HSlider
@onready var tile_separation_label := %TileSeparationLabel as Label
@onready var tile_separation_slider := %TileSeparationSlider as HSlider
@onready var connector_thickness_label := %ConnectorThicknessLabel as Label
@onready var connector_thickness_slider := %ConnectorThicknessSlider as HSlider
@onready var distinct_tiles_option_button := %DistinctTilesOptionButton as OptionButton
@onready var wordlist_option_button := %WordlistOptionButton as OptionButton


func _ready() -> void:
	var video_settings := ConfigHandler.load_settings("video")
	fullscreen_option_button.selected = int(video_settings.fullscreen)
	if fullscreen_option_button.selected:
		borderless_option_button.disabled = true
	borderless_option_button.selected = int(video_settings.borderless)
	
	var audio_settings := ConfigHandler.load_settings("audio")
	master_volume_label.text = _to_percent_string(audio_settings.master_volume)
	master_volume_slider.value = audio_settings.master_volume
	music_volume_label.text = _to_percent_string(audio_settings.music_volume)
	music_volume_slider.value = audio_settings.music_volume
	sfx_volume_label.text = _to_percent_string(audio_settings.sfx_volume)
	sfx_volume_slider.value = audio_settings.sfx_volume
	
	var gameplay_settings := ConfigHandler.load_settings("gameplay")
	tile_separation_label.text = str(gameplay_settings.letter_tile_separation)
	tile_separation_slider.value = gameplay_settings.letter_tile_separation
	connector_thickness_label.text = str(gameplay_settings.connector_thickness)
	connector_thickness_slider.value = gameplay_settings.connector_thickness
	distinct_tiles_option_button.selected = gameplay_settings.distinct_multiplier_tiles
	for idx in wordlist_paths.size():
		var wordlist := wordlist_paths[idx]
		var file_name := wordlist.split("/")[-1]
		wordlist_option_button.add_item(file_name, idx)
		if gameplay_settings.wordlist_path == wordlist:
			wordlist_option_button.selected = idx
	
	var set_borderless := func(idx: int) -> void:
		ConfigHandler.set_borderless_window(bool(idx))
		ConfigHandler.save_settings("video", "borderless", bool(idx))
	borderless_option_button.item_selected.connect(set_borderless)
	fullscreen_option_button.grab_focus()
	fullscreen_option_button.item_selected.connect(func(idx: int) -> void:
		var is_fullscreen := bool(idx)
		# For some reason, having borderless enabled makes you lose focus of
		# the window when going fullscreen. This prevents that by setting the
		# game to borderless right before going fullscreen.
		if is_fullscreen:
			set_borderless.call(0)
			borderless_option_button.selected = false
		borderless_option_button.disabled = is_fullscreen
		ConfigHandler.set_fullscreen(is_fullscreen)
		ConfigHandler.save_settings("video", "fullscreen", is_fullscreen)
	)
	master_volume_slider.value_changed.connect(func(value: float) -> void:
		master_volume_label.text = _to_percent_string(value)
		ConfigHandler.set_volume("Master", value)
		ConfigHandler.save_settings("audio", "master_volume", value)
	)
	music_volume_slider.value_changed.connect(func(value: float) -> void:
		music_volume_label.text = _to_percent_string(value)
		ConfigHandler.set_volume("Music", value)
		ConfigHandler.save_settings("audio", "music_volume", value)
	)
	sfx_volume_slider.value_changed.connect(func(value: float) -> void:
		sfx_volume_label.text = _to_percent_string(value)
		ConfigHandler.set_volume("SFX", value)
		ConfigHandler.save_settings("audio", "sfx_volume", value)
	)
	tile_separation_slider.value_changed.connect(func(value: int) -> void:
		tile_separation_label.text = str(value)
		ConfigHandler.save_settings("gameplay", "letter_tile_separation", value)
	)
	connector_thickness_slider.value_changed.connect(func(value: int) -> void:
		connector_thickness_label.text = str(value)
		ConfigHandler.save_settings("gameplay", "connector_thickness", value)
	)
	distinct_tiles_option_button.item_selected.connect(func(idx: int) -> void:
		ConfigHandler.save_settings("gameplay", "distinct_multiplier_tiles",
				bool(idx))
	)
	wordlist_option_button.item_selected.connect(func(idx: int) -> void:
		var wordlist_path := wordlist_paths[idx]
		ConfigHandler.save_settings("gameplay", "wordlist_path", wordlist_path)
		WordlistHandler.load_wordlist(wordlist_path)
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneHandler.goto_scene("res://menus/main_menu.tscn")


func _to_percent_string(value: float) -> String:
	return str(int(value * 100)) + "%"
