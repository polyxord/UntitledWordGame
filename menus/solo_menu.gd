extends Control


@onready var scrolling_menu := %ScrollingMenu as ScrollingMenu
@onready var grid_container := %GridContainer as GridContainer


func _ready() -> void:
	for child in scrolling_menu.buttons.get_children():
		child.queue_free()
	
	var freeplay_button := Button.new()
	freeplay_button.text = "Freeplay"
	freeplay_button.pressed.connect(func() -> void:
		SceneHandler.goto_scene("res://menus/freeplay_menu.tscn")
	)
	scrolling_menu.buttons.add_child(freeplay_button)
	var marathon_button := Button.new()
	marathon_button.text = "Marathon"
	marathon_button.pressed.connect(func() -> void:
		SceneHandler.goto_scene("res://menus/marathon_menu.tscn")
	)
	scrolling_menu.buttons.add_child(marathon_button)
	marathon_button.focus_neighbor_bottom = freeplay_button.get_path()
	freeplay_button.focus_neighbor_top = marathon_button.get_path()
	
	var angle_offset := 16 * randf()
	var template := "[center][rainbow freq=1.0 sat=0.5 val=1.0]%s[/rainbow][/center]"
	for letter in "SOLO":
		for column in grid_container.columns:
			var control := Control.new()
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			control.size_flags_vertical = Control.SIZE_EXPAND_FILL
			grid_container.add_child(control)
			var label := RichTextLabel.new()
			label.text = template % letter
			label.bbcode_enabled = true
			label.add_theme_font_size_override("normal_font_size", 100)
			label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			control.add_child(label)
			var start_angle := ((column + angle_offset - 1) / 16.0) * TAU
			var end_angle := start_angle - TAU
			var set_label_scale := func(angle: float) -> void:
				label.scale = Vector2(cos(angle), 1.5)
			set_label_scale.call(start_angle)
			var tween := create_tween().set_loops()
			tween.tween_method(set_label_scale, start_angle, end_angle, 2.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneHandler.goto_scene("res://menus/main_menu.tscn")
