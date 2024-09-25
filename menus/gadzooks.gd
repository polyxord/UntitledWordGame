extends Control


func _unhandled_input(event: InputEvent) -> void:
	if (
			event.is_action_pressed("ui_cancel")
			or event.is_action_pressed("ui_accept")
	):
		SceneHandler.goto_scene("res://menus/main_menu.tscn")
