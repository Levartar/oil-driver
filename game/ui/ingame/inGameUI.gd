extends Control

@onready var fps_label: Label = $VBoxContainer/FPSLabel
@onready var velocity_label: Label = $VBoxContainer/VelocityLabel
@onready var reset_button: Button = $VBoxContainer/ResetButton

var player: Node3D


func _find_player() -> Node3D:
	var player_names = ["player", "playercar", "playercharacter"]
	# Search all nodes in the tree
	var all_nodes = get_tree().get_nodes_in_group("all") if get_tree().has_group("all") else []
	if all_nodes.is_empty():
		# Fallback: search manually through the tree
		var root = get_tree().root
		var nodes_to_check = [root]
		while not nodes_to_check.is_empty():
			var node = nodes_to_check.pop_front()
			var node_name_lower = node.name.to_lower()
			for player_name in player_names:
				if node_name_lower == player_name:
					return node
			# Add children to check
			for child in node.get_children():
				nodes_to_check.append(child)
	return null


func _ready() -> void:
	# Find the player in the scene
	player = _find_player()
	
	if player == null:
		push_error("Player node not found in scene!")
	
	# Connect reset button
	reset_button.pressed.connect(_on_reset_button_pressed)


func _process(_delta: float) -> void:
	if player == null:
		player = _find_player()

	# Update FPS
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	
	# Update velocity
	if velocity_label and player:
		if player is VehicleBody3D:
			var velocity_magnitude = player.linear_velocity.length()
			velocity_label.text = "Velocity: %.2f m/s" % velocity_magnitude
		elif player is CharacterBody3D:
			var velocity_magnitude = player.velocity.length()
			velocity_label.text = "Velocity: %.2f m/s" % velocity_magnitude


func _on_reset_button_pressed() -> void:
	get_tree().paused = false
	SceneLoader.reload_current_scene()
