extends Control

@onready var fps_label: Label = $VBoxContainer/FPSLabel
@onready var velocity_label: Label = $VBoxContainer/VelocityLabel
@onready var reset_button: Button = $VBoxContainer/ResetButton

var car: VehicleBody3D


func _ready() -> void:
	# Find the car in the scene
	car = get_tree().root.find_child("Car", true, false)
	
	if car == null:
		push_error("Car node not found in scene!")
	
	# Connect reset button
	reset_button.pressed.connect(_on_reset_button_pressed)


func _process(delta: float) -> void:
	if car == null:
		car = get_tree().root.find_child("Car", true, false)

	# Update FPS
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	
	# Update velocity
	if velocity_label and car:
		var velocity_magnitude = car.linear_velocity.length()
		velocity_label.text = "Velocity: %.2f m/s" % velocity_magnitude


func _on_reset_button_pressed() -> void:
	get_tree().paused = false
	SceneLoader.reload_current_scene()
