extends Area3D
## Proximity detection for car entry
## Detects when player enters range and handles entry interaction

@export var ENTRY_DISTANCE = 3.0

var player: CharacterBody3D = null
var player_in_range: bool = false
var car: VehicleBody3D = null
var interaction_text_instance: Node2D = null
var interaction_text_scene = preload("res://game/ui/ingame/InteractionText.tscn")

func _ready() -> void:
	# Get reference to parent car
	car = get_parent()
	if not (car is VehicleBody3D):
		push_error("CarEntryTrigger must be a child of a VehicleBody3D")
		return
	
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Handle interact input when player is in range
	if player_in_range and player != null and Input.is_action_just_pressed("interact"):
		_trigger_car_entry()

func _on_body_entered(body: Node3D) -> void:
	# Check if it's the player character
	if body.is_in_group("player") or (body.name == "Player"):
		player = body as CharacterBody3D
		player_in_range = true
		_show_interaction_ui()

func _on_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
		player_in_range = false
		_hide_interaction_ui()

func _show_interaction_ui() -> void:
	if interaction_text_instance == null:
		interaction_text_instance = interaction_text_scene.instantiate()
		get_tree().root.add_child(interaction_text_instance)
	
	# Calculate midpoint between player and dialog trigger
	var player_pos = player.global_position
	var trigger_pos = global_position
	var midpoint = (player_pos + trigger_pos) / 2.0
	
	# Project the 3D midpoint to 2D screen coordinates
	var camera = get_viewport().get_camera_3d()
	if camera:
		var screen_pos = camera.unproject_position(midpoint)
		interaction_text_instance.position = screen_pos
		interaction_text_instance.show()

func _hide_interaction_ui() -> void:
	# TODO: Hide interaction UI
	pass

func _trigger_car_entry() -> void:
	if player == null or car == null:
		return
	
	# Call the player's enter_car method
	if player.has_method("enter_car"):
		player.enter_car(car)
