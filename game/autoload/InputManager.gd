extends Node

# Track if a level is currently running
var _is_level_running: bool = false


func _ready() -> void:
	# Connect to scene loading signals to track when a level is active
	SceneLoader.scene_loading_finished.connect(_on_scene_loaded)


func _unhandled_input(event: InputEvent) -> void:
	# Only process input if a level is currently running
	if not _is_level_running:
		return
	
	# Check for pause input (ESC or P or gamepad START)
	if event.is_action_pressed("pause"):
		var paused: bool = not get_tree().paused
		get_tree().paused = paused
		if paused and ResourceLoader.exists("res://game/ui/screens/PauseMenu.tscn"):
			var pause_menu: Node = load("res://game/ui/screens/PauseMenu.tscn").instantiate()
			get_tree().root.add_child(pause_menu)
	
	# Check for reset input (R key or gamepad SELECT)
	# Note: You may need to add a "reset" action in Settings.gd if not already present
	elif event.is_action_pressed("reset"):
		get_tree().paused = false
		SceneLoader.reload_current_scene()


func _on_scene_loaded(_scene_path: String) -> void:
	# Determine if the loaded scene is a level or a menu
	var current_scene = SceneLoader.get_current_scene()
	
	if current_scene == null:
		_is_level_running = false
		return
	
	# Check if scene is a level (negative detection - not a menu)
	var scene_name = current_scene.name
	var is_level = (
		"Level" in scene_name or 
		"level" in scene_name
	)
	
	_is_level_running = is_level


func is_level_running() -> bool:
	return _is_level_running


func set_level_running(value: bool) -> void:
	_is_level_running = value
