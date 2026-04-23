extends Area3D
class_name DialogTrigger

@export var quest_id: String = ""
@export var character_name: String = ""
@export var trigger_once: bool = false
@export var autoplay: bool = false
@export var collectible: bool = false

var dialog_completed = false
var player_in_range = false
var dialog_playing = false
var player: Node3D = null
var original_camera: Camera3D = null
var dialog_camera: Camera3D = null
var interaction_text_instance: Node2D = null
var interaction_text_scene = preload("res://game/ui/ingame/InteractionText.tscn")

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if DialogManager:
		DialogManager.dialog_finished.connect(_on_dialog_finished)
		
func _on_body_entered(body: Node3D) -> void:
	if body.name.to_lower().contains("player"):
		player = body
		player_in_range = true
		if autoplay:
			_trigger_dialog()
		else:
			_show_interaction_text()
		#_trigger_dialog()

func _on_body_exited(body: Node3D):
	"""When player leaves trigger range"""
	if body.name.to_lower().contains("player"):
		player_in_range = false
		player = null
		reset_trigger()
		_hide_interaction_text()

func _trigger_dialog():
	"""Trigger dialogue if conditions are met"""
	if dialog_completed and trigger_once:
		return
	
	if dialog_playing:
		return
	
	if collectible:
		var collectible_node = get_parent()
		if collectible_node and is_node_valid(collectible_node):
			collectible_node.collect_collectible()
		else:
			print("DialogTrigger error: marked as collectible but parent is not a Collectible")
	
	if not quest_id.is_empty():
		print("Starting dialog via DialogManager: %s" % quest_id)
		if DialogManager:
			dialog_playing = true
			_pause_player()
			_switch_to_dialog_camera()
			DialogManager.play_dialog(quest_id)
		dialog_completed = true
	else:
		print("DialogTrigger error: missing dialog_id in quest")

func reset_trigger():
	"""Reset trigger to allow dialogue to play again"""
	pass


func _show_interaction_text() -> void:
	"""Show interaction text positioned between player and dialog trigger"""
	
	# Instantiate the interaction text scene
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
		
		# Show bobbing marker only if dialog is not completed
		var bobbing_marker = interaction_text_instance.find_child("BobbingMarker", true, false)
		if bobbing_marker and not dialog_completed:
			bobbing_marker.show()
		elif bobbing_marker:
			bobbing_marker.hide()


func _hide_interaction_text() -> void:
	"""Hide interaction text"""
	if interaction_text_instance:
		interaction_text_instance.hide()


func _on_interact_input() -> void:
	"""Handle interact input and start dialog"""
	if player_in_range:
		_hide_interaction_text()
		_trigger_dialog()


func _process(_delta: float) -> void:
	"""Check for interact input while player is in range"""
	if player_in_range and Input.is_action_just_pressed("interact"):
		_on_interact_input()


func _pause_player() -> void:
	"""Pause player input, camera stays active"""
	if player:
		if player is VehicleBody3D:
			player.input_disabled = true
			player.linear_velocity = Vector3.ZERO
		elif player is CharacterBody3D:
			player.input_disabled = true
			player.velocity = Vector3.ZERO


func _resume_player() -> void:
	"""Resume player input after dialog"""
	if player:
		if player is VehicleBody3D:
			player.input_disabled = false
		elif player is CharacterBody3D:
			player.input_disabled = false


func _switch_to_dialog_camera() -> void:
	"""Switch to the dialog camera (parent node's Camera3D)"""
	if not get_parent():
		return
	
	dialog_camera = get_parent().find_child("Camera3D", true, false) as Camera3D
	if not dialog_camera:
		print("DialogTrigger: No Camera3D found in parent")
		return
	
	# Store the current active camera
	var current_camera = get_viewport().get_camera_3d()
	if current_camera and current_camera != dialog_camera:
		original_camera = current_camera
		dialog_camera.make_current()


func _switch_back_to_original_camera() -> void:
	"""Switch back to the original camera"""
	if original_camera and is_node_valid(original_camera):
		original_camera.make_current()
		print("DialogTrigger: Switched back to original camera")
		original_camera = null


func is_node_valid(node: Node) -> bool:
	"""Check if a node is still valid and in the scene tree"""
	return node and not node.is_queued_for_deletion() and node.get_parent()


func _on_dialog_finished() -> void:
	"""Called when DialogManager finishes playing dialog"""
	dialog_playing = false
	_resume_player()
	_switch_back_to_original_camera()
	# Show interaction text again if player is still in range
	if player_in_range and not autoplay:
		_show_interaction_text()
