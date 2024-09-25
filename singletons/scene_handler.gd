## A singleton that manages scene switching.
## 
## @tutorial(Custom Scene Switcher): https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html#custom-scene-switcher
## @tutorial(Background Loading): https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html#doc-background-loading 
extends CanvasLayer


var _current_scene: Node = null

@onready var _animation_player := %AnimationPlayer as AnimationPlayer


func _ready() -> void:
	_current_scene = get_tree().root.get_child(-1)
	hide()


## Switches the current scene to the [param path] file scene.[br]
## [br]
## If [param fade_transition] is [code]true[/code], a fade transition will play
## when switching scenes.[br]
## [br]
## Before the new scene is added to the scene tree, [param transition_func] is
## called. This allows you to transfer data between scenes.
func goto_scene(path: String = "res://menus/gadzooks.tscn",
		fade_transition: bool = true,
		transition_func: Callable = func(): pass) -> void:
	ResourceLoader.load_threaded_request(path)
	if fade_transition:
		call_deferred("_fade_to_scene", path, transition_func)
	else:
		call_deferred("_change_to_scene", path, transition_func)


## Switches the current scene to gameplay to play [param rounds] with
## [param rng_seed].
func goto_level(rounds: Array[Round], rng_seed: int = 0) -> void:
	goto_scene("res://gameplay/game.tscn", true, func() -> void:
		_current_scene.rounds = rounds
		if rng_seed != 0:
			_current_scene.rng_seed = rng_seed
	)


## Switches the current scene to the scene at [param path] with a fade
## transition. Calls [param transition_func] when switching.[br]
## [br]
## For transitionless scene switching, see [method _change_to_scene].
func _fade_to_scene(path: String, transition_func: Callable) -> void:
	show()
	_animation_player.play("fade")
	await _animation_player.animation_finished
	
	_change_to_scene(path, transition_func)
	_animation_player.play_backwards("fade")
	await _animation_player.animation_finished
	
	hide()


## Switches the current scene to the scene at [param path]. Calls
## [param transition_func] when switching.[br]
## [br]
## For scene switching with a fade transition, see [method _fade_to_scene].
func _change_to_scene(path: String, transition_func: Callable) -> void:
	_current_scene.free()
	var new_scene := ResourceLoader.load_threaded_get(path) as PackedScene
	_current_scene = new_scene.instantiate()
	transition_func.call()
	get_tree().root.add_child(_current_scene)
	# To make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = _current_scene
