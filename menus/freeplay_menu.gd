extends Control


@export var letter_distributions: Array[LetterDistribution]
@export var game_modes: Array[String]
@export var grid_layouts: Array[GridLayout]

@onready var min_word_length_spin_box = %MinWordLengthSpinBox as SpinBox
@onready var letter_distribution_option_button := %LetterDistributionOptionButton as OptionButton
@onready var game_mode_option_button := %GameModeOptionButton as OptionButton
@onready var sprint_time := %SprintTime as HBoxContainer
@onready var sprint_time_spin_box := %SprintTimeSpinBox as SpinBox
@onready var percent_to_find := %PercentToFind as HBoxContainer
@onready var percent_to_find_spin_box := %PercentToFindSpinBox as SpinBox
@onready var grid_layout_option_button := %GridLayoutOptionButton as OptionButton
@onready var grid_seed_line_edit := %GridSeedLineEdit as LineEdit
@onready var start_button := %StartButton as Button


func _ready() -> void:
	var freeplay_settings := ConfigHandler.load_settings("freeplay")
	min_word_length_spin_box.value = freeplay_settings.min_word_length
	for idx in letter_distributions.size():
		var letter_distribution := letter_distributions[idx]
		letter_distribution_option_button.add_item(letter_distribution.name, idx)
		if freeplay_settings.letter_distribution.name == letter_distribution.name:
			letter_distribution_option_button.selected = idx
	for idx in game_modes.size():
		var game_mode := game_modes[idx]
		game_mode_option_button.add_item(game_mode, idx)
		if freeplay_settings.game_mode == game_mode:
			game_mode_option_button.selected = idx
		match freeplay_settings.game_mode:
			"Archaeologist":
				sprint_time.hide()
				percent_to_find.show()
	sprint_time_spin_box.value = freeplay_settings.sprint_time
	percent_to_find_spin_box.value = freeplay_settings.percent_to_find
	for idx in grid_layouts.size():
		var grid_layout := grid_layouts[idx]
		grid_layout_option_button.add_item(grid_layout.name, idx)
		if freeplay_settings.grid_layout.name == grid_layout.name:
			grid_layout_option_button.selected = idx
			
	min_word_length_spin_box.value_changed.connect(func(value: int) -> void:
		ConfigHandler.save_settings("freeplay", "min_word_length", value)
	)
	letter_distribution_option_button.item_selected.connect(func(idx: int) -> void:
		ConfigHandler.save_settings("freeplay", "letter_distribution", 
				letter_distributions[idx])
	)
	game_mode_option_button.item_selected.connect(func(idx: int) -> void:
		var game_mode := game_modes[idx]
		ConfigHandler.save_settings("freeplay", "game_mode", game_mode)
		match game_mode:
			"Sprint":
				sprint_time.show()
				percent_to_find.hide()
			"Archaeologist":
				sprint_time.hide()
				percent_to_find.show()
	)
	sprint_time_spin_box.value_changed.connect(func(value: int) -> void:
		ConfigHandler.save_settings("freeplay", "sprint_time", value)
	)
	percent_to_find_spin_box.value_changed.connect(func(value: int) -> void:
		ConfigHandler.save_settings("freeplay", "percent_to_find", value)
	)
	grid_layout_option_button.item_selected.connect(func(idx: int) -> void:
		ConfigHandler.save_settings("freeplay", "grid_layout", grid_layouts[idx])
	)
	start_button.grab_focus()
	start_button.pressed.connect(func() -> void:
		var current_freeplay_settings := ConfigHandler.load_settings("freeplay")
		if current_freeplay_settings.game_mode == "Sprint":
			var new_round := SprintRound.new()
			new_round.grid_layout = current_freeplay_settings.grid_layout
			new_round.letter_distribution = current_freeplay_settings.letter_distribution
			new_round.min_word_length = current_freeplay_settings.min_word_length
			new_round.sprint_time = current_freeplay_settings.sprint_time
			SceneHandler.goto_level([new_round], int(grid_seed_line_edit.text))
		elif current_freeplay_settings.game_mode == "Archaeologist":
			var new_round := ArchaeologistRound.new()
			new_round.grid_layout = current_freeplay_settings.grid_layout
			new_round.letter_distribution = current_freeplay_settings.letter_distribution
			new_round.min_word_length = current_freeplay_settings.min_word_length
			new_round.percent_to_find = current_freeplay_settings.percent_to_find
			SceneHandler.goto_level([new_round], int(grid_seed_line_edit.text))
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneHandler.goto_scene("res://menus/solo_menu.tscn")
