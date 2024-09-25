extends Control

const _LETTER_TILE = preload("res://gameplay/letter_tile.tscn")
const _MULTIPLIER_TILE_TEXTURE = preload("res://assets/letter_tile_textures/multiplier_tile_texture.tres")
const _TILE_MASK_2 = preload("res://assets/image_masks/tile_mask_2.png")
const _DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 1),
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(-1, 1),
	Vector2i(1, -1),
	Vector2i(-1, -1),
	Vector2i(-1, 0),
	Vector2i(0, -1),
]
@export var rounds: Array[Round] = []
@export_file var _background_file_paths: Array[String]
@export var _valid_word_sfx: AudioStream
var rng_seed: int
var _wordlist: PackedStringArray
var _random: RandomNumberGenerator
var _gameplay_settings: Dictionary
var _current_round_index := 0
var _current_round_num:
	get():
		return _current_round_index + 1
var _current_round: Round
var _found_words: PackedStringArray
var _grid_coord_to_letter: Dictionary
var _valid_word_to_score: Dictionary
var _total_score := 0:
	set(new_score):
		_total_score = new_score
		total_score_label.text = "Total score: " + str(_total_score)
var _round_score := 0:
	set(new_score):
		_round_score = new_score
		round_score_label.text = "Round score: " + str(_round_score)
var _timer: SceneTreeTimer
var _current_layout: GridLayout
var _num_words_needed: int:
	set(value):  
		_num_words_needed = value
		num_words_needed_label.text = str(value)
@onready var background := %Background as TextureRect
@onready var round_info_label := %RoundInfoLabel as Label
@onready var round_info_label_2 := %RoundInfoLabel2 as Label
@onready var seed_label := %SeedLabel as RichTextLabel
@onready var letter_grid := %LetterGrid as GridContainer
@onready var line_grid := %LineGrid as Control
@onready var line_edit := %LineEdit as LineEdit
@onready var continue_button := %ContinueButton as Button
@onready var total_word_count_label := %TotalWordCountLabel as Label
@onready var discovered_word_count_label := %DiscoveredWordCountLabel as Label
@onready var total_score_label := %TotalScoreLabel as Label
@onready var round_score_label := %RoundScoreLabel as Label
@onready var timed_round_info := %TimedRoundInfo as VBoxContainer
@onready var time_left_label := %TimeLeftLabel as Label
@onready var archeo_round_info := %ArcheoRoundInfo as VBoxContainer
@onready var num_words_needed_label := %NumWordsNeededLabel as Label
@onready var missed_word_list := %MissedWordList as VBoxContainer
@onready var missed_words_label := %MissedWordsLabel as Label
@onready var guessed_word_list := %GuessedWordList as VBoxContainer
@onready var guessed_words_scroll_container := %GuessedWordsScrollContainer as ScrollContainer


func _ready() -> void:
	background.texture = load(_background_file_paths.pick_random())
	_wordlist = WordlistHandler.wordlist
	_random = RandomNumberGenerator.new()
	if rng_seed:
		_random.seed = rng_seed
	seed_label.text = "[center]Seed: [url]%s[/url][/center]" % [_random.seed]
	seed_label.meta_clicked.connect(func(meta: Variant) -> void:
		DisplayServer.clipboard_set(str(meta))
	)
	line_edit.text_submitted.connect(_submit_word)
	line_edit.text_changed.connect(func(word: String) -> void:
		if word != "" and word[-1] == " ":
			_submit_word(word)
	)
	continue_button.pressed.connect(func() -> void:
		_current_round_index += 1
		if _current_round_index < rounds.size():
			continue_button.hide()
			line_edit.show()
			_setup_new_round()
		else:
			SceneHandler.goto_scene()
	)
	guessed_word_list.child_entered_tree.connect(func(_a: Node) -> void:
		var scroll_bar := guessed_words_scroll_container.get_v_scroll_bar()
		await scroll_bar.changed
		
		guessed_words_scroll_container.scroll_vertical = int(scroll_bar.max_value)
	)
	_gameplay_settings = ConfigHandler.load_settings("gameplay")
	letter_grid.add_theme_constant_override("h_separation",
			_gameplay_settings.letter_tile_separation)
	letter_grid.add_theme_constant_override("v_separation",
			_gameplay_settings.letter_tile_separation)
	_setup_new_round()


func _process(_delta: float) -> void:
	if _timer and _timer.time_left > 0:
		time_left_label.text = str(_timer.time_left).pad_decimals(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneHandler.goto_scene("res://menus/solo_menu.tscn")


func _setup_new_round() -> void:
	continue_button.disabled = true
	missed_words_label.hide()
	discovered_word_count_label.text = "0"
	for child in line_grid.get_children():
		child.queue_free()
	for child in letter_grid.get_children():
		child.queue_free()
	for child in guessed_word_list.get_children():
		child.queue_free()
	for child in missed_word_list.get_children():
		child.queue_free()
	_round_score = 0
	_found_words = []
	_grid_coord_to_letter = {}
	_valid_word_to_score = {}
	_current_round = rounds[_current_round_index]
	_current_layout = _current_round.grid_layout
	round_info_label.text = "Round: %s of %s" % [_current_round_num, rounds.size()]
	round_info_label_2.text = _current_round.description
	line_edit.text = ""
	line_edit.editable = true
	line_edit.grab_focus()

	var letter_counts := _current_round.letter_distribution.letter_counts
	var letter_distribution: Array[String] = []
	for letter in letter_counts:
		for _count in letter_counts[letter]:
			letter_distribution.append(letter)
	
	var grid_coordinates: Array[Vector2i] = []
	for y_coord in range(1, _current_layout.grid_size.y + 1):
		for x_coord in range(1, _current_layout.grid_size.x + 1):
			grid_coordinates.append(Vector2i(x_coord, y_coord))
	var grid_width := _current_layout.grid_size.x
	letter_grid.columns = grid_width
	
	for coord in grid_coordinates:
		var letter := ""
		if coord not in _current_layout.blank_coords:
			var random_index := _random.randi_range(0, letter_distribution.size() - 1)
			letter = letter_distribution.pop_at(random_index)
		_grid_coord_to_letter[coord] = letter.to_lower()
		var letter_tile := _LETTER_TILE.instantiate()
		letter_grid.add_child(letter_tile)
		var letter_label: Label = letter_tile.letter
		letter_label.text = letter.capitalize()
		if letter == "":
			letter_tile.modulate.a = 0
		if coord in _current_layout.multiplier_coords:
			letter_tile.texture_rect.texture = _MULTIPLIER_TILE_TEXTURE
			if _gameplay_settings.distinct_multiplier_tiles:
				letter_tile.mask.texture = _TILE_MASK_2
	
	await get_tree().process_frame
	letter_grid.anchor_left = 0.5
	letter_grid.anchor_right = 0.5
	letter_grid.anchor_top = 0.5
	letter_grid.anchor_bottom = 0.5
	letter_grid.pivot_offset = letter_grid.size / 2.0
	line_grid.size = letter_grid.size
	line_grid.anchor_left = 0.5
	line_grid.anchor_right = 0.5
	line_grid.anchor_top = 0.5
	line_grid.anchor_bottom = 0.5
	line_grid.position = letter_grid.position
	line_grid.pivot_offset = letter_grid.pivot_offset
	
	var max_grid_height: float = letter_grid.get_parent().size.y
	var max_grid_size := maxf(letter_grid.size.y, letter_grid.size.x)
	var grid_scale_factor := max_grid_height / max_grid_size
	letter_grid.scale = Vector2(grid_scale_factor, grid_scale_factor)
	line_grid.scale = Vector2(grid_scale_factor, grid_scale_factor)
	
	var idx := 0
	var grid_coord_to_viewport_coord: Dictionary = {}
	for coord: Vector2i in _grid_coord_to_letter:
		var tile: LetterTile = letter_grid.get_child(idx)
		grid_coord_to_viewport_coord[coord] = tile.position + tile.pivot_offset
		idx += 1
	
	var already_lined_coords: Dictionary = {}
	for grid_coord: Vector2i in grid_coord_to_viewport_coord:
		if _grid_coord_to_letter[grid_coord] == "":
			continue
		
		for direction in _DIRECTIONS:
			var neighbor_coord := grid_coord + direction
			if neighbor_coord not in _grid_coord_to_letter:
				continue
			
			if _grid_coord_to_letter[neighbor_coord] == "":
				continue
			
			var opposite_coords := Vector4i(neighbor_coord.x, neighbor_coord.y,
					grid_coord.x, grid_coord.y)
			if opposite_coords in already_lined_coords:
				continue
			
			var lined_coords := Vector4i(grid_coord.x, grid_coord.y,
					neighbor_coord.x, neighbor_coord.y)
			already_lined_coords[lined_coords] = true
			var line := Line2D.new()
			line_grid.add_child(line)
			line.width = _gameplay_settings.connector_thickness
			line.default_color = Color(0.0, 0.0, 0.0, 1.0)
			line.add_point(grid_coord_to_viewport_coord[grid_coord])
			line.add_point(grid_coord_to_viewport_coord[neighbor_coord])
	
	for current_coord: Vector2i in _grid_coord_to_letter:
		var current_string: String = _grid_coord_to_letter[current_coord]
		var traveled_coords := {} 
		var score_multiplier := 1 
		if current_coord in _current_layout.multiplier_coords:
			score_multiplier *= 2
		traveled_coords[current_coord] = true
		_find_valid_words(traveled_coords, current_coord, current_string, score_multiplier)
	
	total_word_count_label.text = str(_valid_word_to_score.size())
	if _valid_word_to_score.is_empty():
		_end_game()
		return
	
	if _current_round is SprintRound:
		timed_round_info.show()
		_timer = get_tree().create_timer(1.0 + _current_round.sprint_time)
		_timer.timeout.connect(_end_game)
	elif _current_round is ArchaeologistRound:
		archeo_round_info.show()
		var clear_percent: float = 0.01 * _current_round.percent_to_find
		var total_valid_words := _valid_word_to_score.size()
		_num_words_needed = maxi(1, roundi(clear_percent * total_valid_words))


func _end_game() -> void:
	if _current_round is SprintRound:
		_timer = null
		time_left_label.text = "🐙💬🛑"
	line_edit.editable = false
	missed_words_label.show()
	for word: String in _valid_word_to_score:
		if word not in _found_words:
			var label := Label.new()
			label.text = word
			missed_word_list.add_child(label)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(line_edit, "position:x", -200.0, 0.25)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(line_edit, "position:x", 600.0, 0.5)
	tween.finished.connect(func() -> void:
		line_edit.hide()
		continue_button.show()
		await get_tree().create_timer(1.0).timeout
		
		continue_button.disabled = false
		continue_button.grab_focus()
	)


func _submit_word(word: String) -> void:
	if not line_edit.editable:
		return
	
	line_edit.text = ""
	var stripped_word := word.to_lower().strip_edges()
	if stripped_word == "42":
		_current_round_index = rounds.size()
		_end_game()
		return
	
	if stripped_word not in _valid_word_to_score:
		return
	
	var guessed_word_score: int = _valid_word_to_score[stripped_word]
	var word_is_already_guessed := guessed_word_score == 0
	if word_is_already_guessed:
		return
	
	var guessed_word_label := Label.new()
	guessed_word_label.text = stripped_word + " " + str(guessed_word_score)
	guessed_word_list.add_child(guessed_word_label)
	_total_score += guessed_word_score
	_round_score += guessed_word_score
	_found_words.append(stripped_word)
	discovered_word_count_label.text = str(_found_words.size())
	_valid_word_to_score[stripped_word] = 0
	SoundHandler.play_sfx(_valid_word_sfx, true)
	if _current_round is ArchaeologistRound:
		_num_words_needed -= 1
		if _num_words_needed <= 0:
			_end_game()
	elif _valid_word_to_score.size() == _found_words.size():
		_end_game()


func _find_valid_words(traveled_coords: Dictionary, current_coord: Vector2i,
		current_string: String, score_multiplier: int) -> void:
	for direction in _DIRECTIONS:
		var new_coord := current_coord + direction
		var new_score_multiplier := score_multiplier
		if new_coord in _current_layout.multiplier_coords:
			new_score_multiplier *= 2
		if new_coord not in _grid_coord_to_letter:
			continue
		
		if new_coord in traveled_coords:
			continue
		
		var new_letter: String = _grid_coord_to_letter[new_coord]
		if new_letter == "":
			continue
		
		var new_string := current_string + new_letter
		var bsearch_index := _wordlist.bsearch(new_string)
		if bsearch_index == _wordlist.size():
			continue
		
		var current_word := _wordlist[bsearch_index]
		var new_string_is_word := current_word == new_string
		if new_string_is_word and new_string.length() >= _current_round.min_word_length:
			var word_score := 2 ** (new_string.length() - 2)
			word_score *= new_score_multiplier
			
			if new_string in _valid_word_to_score:
				_valid_word_to_score[new_string] = maxi(_valid_word_to_score[new_string], word_score)
			else:
				_valid_word_to_score[new_string] = word_score
		
		var next_word := current_word
		if new_string_is_word and bsearch_index + 1 < _wordlist.size():
			next_word = _wordlist[bsearch_index + 1]
		var can_continue := (
				next_word.length() >= new_string.length()
				and next_word[new_string.length() - 1] == new_string[-1]
		)
		if can_continue:
			var new_traveled_coords := traveled_coords.duplicate()
			new_traveled_coords[new_coord] = true
			_find_valid_words(new_traveled_coords, new_coord, new_string, new_score_multiplier)
