extends Control


const VARIETY_1 = preload("res://gameplay/letter_distributions/variety1.tres")

@export var wurd_marathon_grid_layouts: Array[GridLayout]
@export var archaeo_60_marathon_layouts: Array[GridLayout]
@export var archaeo_65_marathon_layouts: Array[GridLayout]
@export var archaeo_70_marathon_layouts: Array[GridLayout]
@export var archaeo_75_marathon_layouts: Array[GridLayout]
@export var archaeo_78_marathon_layouts: Array[GridLayout]
@export var archaeo_81_marathon_layouts: Array[GridLayout]

@onready var scrolling_menu := %ScrollingMenu as ScrollingMenu
@onready var marathon_1 := %Marathon1 as Node2D
@onready var marathon_2 := %Marathon2 as Node2D
@onready var marathon_3 := %Marathon3 as Node2D


func _ready() -> void:
	for child in scrolling_menu.buttons.get_children():
		child.queue_free()
	
	var wurd_button := Button.new()
	wurd_button.text = "Wurd Racer"
	scrolling_menu.buttons.add_child(wurd_button)
	wurd_button.pressed.connect(func() -> void:
		var rounds: Array[Round] = []
		for grid_layout in wurd_marathon_grid_layouts:
			var new_round := SprintRound.new()
			new_round.grid_layout = grid_layout
			new_round.letter_distribution = VARIETY_1
			new_round.min_word_length = 2
			new_round.sprint_time = 120
			rounds.append(new_round)
		SceneHandler.goto_level(rounds)
	)
	var archaeo_layouts_to_percent := {
		archaeo_60_marathon_layouts: 60,
		archaeo_65_marathon_layouts: 65,
		archaeo_70_marathon_layouts: 70,
		archaeo_75_marathon_layouts: 75,
		archaeo_78_marathon_layouts: 78,
		archaeo_81_marathon_layouts: 81,
	}
	for layouts in archaeo_layouts_to_percent:
		var archaeo_button := Button.new()
		var percent_clear: int = archaeo_layouts_to_percent[layouts]
		archaeo_button.text = "Archaeo" + str(percent_clear)
		scrolling_menu.buttons.add_child(archaeo_button)
		archaeo_button.pressed.connect(func() -> void:
			var rounds: Array[Round] = []
			for grid_layout in layouts:
				var new_round := ArchaeologistRound.new()
				new_round.grid_layout = grid_layout
				new_round.letter_distribution = VARIETY_1
				new_round.min_word_length = 2
				new_round.percent_to_find = percent_clear
				rounds.append(new_round)
			SceneHandler.goto_level(rounds)
		)
	
	var tween := create_tween().set_loops()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var tween_duration := 1.3
	tween.set_parallel()
	tween.tween_property(marathon_1, "scale", Vector2(0.5, 1.5), tween_duration)
	tween.tween_property(marathon_1, "skew", deg_to_rad(50), tween_duration)
	tween.chain()
	tween.tween_property(marathon_1, "scale", Vector2(1.0, 0.5), tween_duration)
	tween.tween_property(marathon_1, "skew", 0.0, tween_duration)
	tween.chain()
	tween.tween_property(marathon_1, "scale", Vector2(0.5, 1.5), tween_duration)
	tween.tween_property(marathon_1, "skew", deg_to_rad(-50), tween_duration)
	tween.chain()
	tween.tween_property(marathon_1, "scale", Vector2(1.0, 0.5), tween_duration)
	tween.tween_property(marathon_1, "skew", 0.0, tween_duration)
	
	var other_nodes: Array[Node2D] = [marathon_2, marathon_3]
	for node in other_nodes:
		var tween_2 := create_tween().set_loops()
		tween_2.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween_2.set_parallel()
		tween_2.tween_property(node, "scale", Vector2(1.0, 0.5), tween_duration)
		tween_2.tween_property(node, "skew", 0.0, tween_duration)
		tween_2.chain()
		tween_2.tween_property(node, "scale", Vector2(0.5, 1.5), tween_duration)
		tween_2.tween_property(node, "skew", deg_to_rad(-50), tween_duration)
		tween_2.chain()
		tween_2.tween_property(node, "scale", Vector2(1.0, 0.5), tween_duration)
		tween_2.tween_property(node, "skew", 0.0, tween_duration)
		tween_2.chain()
		tween_2.tween_property(node, "scale", Vector2(0.5, 1.5), tween_duration)
		tween_2.tween_property(node, "skew", deg_to_rad(50), tween_duration)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneHandler.goto_scene("res://menus/solo_menu.tscn")
