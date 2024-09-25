class_name ScrollingMenu
extends ScrollContainer


const _BUTTON_SPACING = 62

var _button_y_positions: Array[float] = []
var _scroll_value: float

@onready var _scroll_timer := %ScrollTimer as Timer
@onready var _margin_container := %MarginContainer as MarginContainer
@onready var _solo_button := %SoloButton as Button
@onready var _multi_button := %MultiButton as Button
@onready var _settings_button := %SettingsButton as Button
@onready var _quit_button := %QuitButton as Button
@onready var buttons := %Buttons as VBoxContainer


func _ready() -> void:
	_solo_button.pressed.connect(func() -> void:
		SceneHandler.goto_scene("res://menus/solo_menu.tscn")
	)
	_multi_button.pressed.connect(SceneHandler.goto_scene)
	_settings_button.pressed.connect(func() -> void:
		SceneHandler.goto_scene("res://menus/settings_menu.tscn")
	)
	_quit_button.pressed.connect(get_tree().quit)
	var margin_size := int((get_viewport_rect().size.y - _BUTTON_SPACING) / 2)
	_margin_container.add_theme_constant_override("margin_bottom", margin_size)
	_margin_container.add_theme_constant_override("margin_top", margin_size)
	await get_tree().process_frame
	
	var inactive_button_opacity := 0.7
	for button: Button in buttons.get_children():
		_button_y_positions.append(button.position.y)
		button.modulate.a = inactive_button_opacity
		button.focus_entered.connect(func() -> void:
			button.modulate.a = 1.0
			var tween := create_tween()
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self, "scroll_vertical", button.position.y,
					0.16)
		)
		button.focus_exited.connect(func() -> void:
			button.modulate.a = inactive_button_opacity
		)
	_scroll_timer.timeout.connect(func() -> void:
		var scroll_position := int(_scroll_value - _BUTTON_SPACING / 2.0)
		var button_idx := _button_y_positions.bsearch(scroll_position)
		var nearest_button := buttons.get_child(button_idx) as Button
		if not nearest_button.has_focus():
			nearest_button.grab_focus()
	)
	get_v_scroll_bar().value_changed.connect(func(value: float) -> void:
		_scroll_value = value
		_scroll_timer.start(0.5)
	)
	buttons.get_child(0).grab_focus()
