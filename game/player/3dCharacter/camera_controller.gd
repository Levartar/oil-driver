extends Node3D

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity :=0.25
@onready var _cameraTarget: Node3D = %CameraTarget

var _camera_input_direction:= Vector2.ZERO
var parent
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent_node_3d()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_cameraTarget.rotation.x += _camera_input_direction.y * delta
		_cameraTarget.rotation.x = clamp(_cameraTarget.rotation.x,-PI/6.0,PI/3.0)
		_cameraTarget.rotation.y -= _camera_input_direction.x * delta
	
func _input(event: InputEvent) -> void:
	#print("event", event)
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		print("mouse captured")
	if event.is_action_pressed("ui_cancel") || event.is_action_released("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative*mouse_sensitivity
