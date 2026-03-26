extends Control

@onready var game_buttons: VBoxContainer = $CenterContainer/VBoxContainer/GameButtons
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton
@onready var title: Label = $CenterContainer/VBoxContainer/GameTitle

var discovered_levels: Array[String] = []


func _ready() -> void:
	_discover_levels()
	_create_level_buttons()
	_setup_navigation()
	_apply_translations()
	back_button.pressed.connect(_on_back_pressed)


func _process(_delta: float) -> void:
	pass


## Discover all level files in res://game/levels/
func _discover_levels() -> void:
	discovered_levels.clear()
	
	var dir = DirAccess.open("res://game/levels/")
	if dir == null:
		push_error("Failed to open levels directory: res://game/levels/")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		# Only include .tscn files and skip special files
		if file_name.ends_with(".tscn") and not file_name.begins_with("."):
			var full_path = "res://game/levels/" + file_name
			discovered_levels.append(full_path)
			print("Discovered level: ", file_name)
		file_name = dir.get_next()
	
	# Sort levels alphabetically for consistent ordering
	discovered_levels.sort()


## Dynamically create buttons for each discovered level
func _create_level_buttons() -> void:
	if discovered_levels.is_empty():
		return
	
	for level_path: String in discovered_levels:
		# Extract level name from file path (e.g., "TestLevel" from "res://game/levels/TestLevel.tscn")
		var level_name = level_path.get_file().trim_suffix(".tscn")
		
		# Create button
		var button = Button.new()
		button.text = level_name
		button.custom_minimum_size = Vector2(250, 50)
		
		# Store level path as metadata for loading later
		button.set_meta("level_path", level_path)
		
		# Connect button signal to handler
		button.pressed.connect(_on_level_button_pressed.bindv([level_path]))
		
		# Add button to container
		game_buttons.add_child(button)


## Handle level button press
func _on_level_button_pressed(level_path: String) -> void:
	print("Loading level: ", level_path)
	SceneLoader.goto_scene(level_path)


## Handle back button press
func _on_back_pressed() -> void:
	SceneLoader.goto_scene("res://game/ui/screens/PlayGame.tscn")


## Setup focus navigation for keyboard/controller support
func _setup_navigation() -> void:
	# Get all buttons (level buttons + back button)
	var all_buttons: Array[Node] = []
	
	for child in game_buttons.get_children():
		if child is Button:
			all_buttons.append(child)
	
	all_buttons.append(back_button)


## Apply translation strings to UI elements
func _apply_translations() -> void:
	title.text = tr("LEVEL_SELECT")
	back_button.text = tr("BACK")
