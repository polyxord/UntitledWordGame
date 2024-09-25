extends Control


@onready var scrolling_menu := %ScrollingMenu as ScrollingMenu
@onready var untitled := %Untitled as Node2D
@onready var word := %Word as Node2D
@onready var game := %Game as Node2D


func _ready() -> void:
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(untitled, "skew", deg_to_rad(30), 1.0)
	tween.parallel().tween_property(word, "skew", deg_to_rad(-30), 1.0)
	tween.parallel().tween_property(game, "skew", deg_to_rad(30), 1.0)
	tween.tween_property(untitled, "skew", deg_to_rad(20), 1.0)
	tween.parallel().tween_property(word, "skew", deg_to_rad(-20), 1.0)
	tween.parallel().tween_property(game, "skew", deg_to_rad(20), 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
