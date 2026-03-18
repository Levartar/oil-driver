extends VehicleBody3D
@export var MAX_STEER = 0.2
@export var ENGINE_POWER = 4000

# Camera view transforms (stored as variables since Transform3D isn't a constant expression)
var isometric_transform: Transform3D 
var third_person_transform: Transform3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize camera transforms
	# This is a bit hacky, but Transform3D can't be a constant expression so we have to initialize it in code instead of as a constant.
	isometric_transform = Transform3D(
		Vector3(-0.57922804, 0.5735765, 0.57922804),
		Vector3(0.40557986, 0.8191522, -0.40557986),
		Vector3(-0.70710677, 0, -0.70710677),
		Vector3(-0.5, 3.5, 3.5)
	)
	third_person_transform = Transform3D(
		Vector3(-0.8152087, 0.57916737, -8.422487e-08),
		Vector3(0.5791675, 0.81520885, -2.3428884e-08),
		Vector3(5.5091608e-08, -6.7879725e-08, -1),
		Vector3(-2.897276, 3.5085611, 0)
	)
	
	_apply_saved_camera_view()
	Settings.setting_changed.connect(_on_setting_changed)
	InputManager.camera_view_toggled.connect(_toggle_camera_view)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("right","left")*MAX_STEER,delta*10)
	var engine_multiplier = 1.0
	
	# Apply testing acceleration multipliers
	# Not good code. This should be refactored to be cleaner and more maintainable, but it works for now.
	if Settings.get_setting("auto_acceleration", false):
		engine_force = ENGINE_POWER * engine_multiplier
	else:
		engine_force = ENGINE_POWER * Input.get_axis("down","up")

	# Camera Controller
	$CameraController.position = lerp($CameraController.position, position, 0.05)
	var current_quat = Quaternion.from_euler($CameraController.rotation)
	var target_quat = Quaternion.from_euler(rotation)
	$CameraController.rotation = current_quat.slerp(target_quat, 0.1).get_euler()

func _apply_saved_camera_view() -> void:
	var camera_view = Settings.get_setting("camera_view", "isometric")
	var target_transform = isometric_transform if camera_view == "isometric" else third_person_transform
	$CameraController/CameraTarget.transform = target_transform

func _toggle_camera_view() -> void:
	var current_view = Settings.get_setting("camera_view", "isometric")
	var new_view = "third_person" if current_view == "isometric" else "isometric"
	Settings.set_setting("camera_view", new_view)

func _on_setting_changed(setting_name: String, _value) -> void:
	if setting_name == "camera_view":
		_apply_saved_camera_view()
