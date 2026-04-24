extends Control

@onready var auto_acceleration_check = $CenterContainer/VBoxContainer/AutoAccelerationRow/AutoAccelerationCheck
@onready var camera_view_check = $CenterContainer/VBoxContainer/CameraViewRow/CameraViewCheck
@onready var input_acceleration_check = $CenterContainer/VBoxContainer/InputAccelerationRow/InputAccelerationCheck
@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var title = $CenterContainer/VBoxContainer/Title
@onready var auto_acceleration_label = $CenterContainer/VBoxContainer/AutoAccelerationRow/AutoAccelerationLabel
@onready var camera_view_label = $CenterContainer/VBoxContainer/CameraViewRow/CameraViewLabel
@onready var debug_check = $CenterContainer/VBoxContainer/DebugViewRow/DebugViewCheck

func _ready():
	add_to_group("translatable")
	if auto_acceleration_check:
		auto_acceleration_check.button_pressed = Settings.get_setting("auto_acceleration")
		auto_acceleration_check.toggled.connect(_on_auto_acceleration_toggled)
	if camera_view_check:
		var is_isometric = Settings.get_setting("camera_view") == "isometric"
		camera_view_check.button_pressed = is_isometric
		camera_view_check.toggled.connect(_on_camera_view_toggled)
	if debug_check:
		var debug = Settings.get_setting("debug")
		debug_check.button_pressed = debug
		debug_check.toggled.connect(_on_debug_toggled)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	Settings.setting_changed.connect(_on_setting_changed)
	_setup_navigation()
	_apply_translations()
	if auto_acceleration_check:
		auto_acceleration_check.grab_focus()

func _on_setting_changed(setting_name: String, _value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	if title: title.text = tr("TESTING_SETTINGS")
	if auto_acceleration_label: auto_acceleration_label.text = tr("AUTO_ACCELERATION")
	if camera_view_label: camera_view_label.text = tr("ISOMETRIC_CAMERA")
	if back_button: back_button.text = tr("BACK")

func _setup_navigation():
	var controls = [auto_acceleration_check, camera_view_check, back_button]
	for i in range(controls.size()):
		if controls[i]:
			var prev_idx = (i - 1 + controls.size()) % controls.size()
			var next_idx = (i + 1) % controls.size()
			controls[i].focus_neighbor_top = controls[prev_idx].get_path()
			controls[i].focus_neighbor_bottom = controls[next_idx].get_path()

func _on_auto_acceleration_toggled(pressed: bool):
	Settings.set_setting("auto_acceleration", pressed)
	Settings.apply_settings()

func _on_camera_view_toggled(pressed: bool):
	var new_view = "isometric" if pressed else "third_person"
	Settings.set_setting("camera_view", new_view)
	
func _on_debug_toggled(pressed: bool):
	var new_debug = true if pressed else false
	Settings.set_setting("debug", new_debug)

func _on_back_pressed():
	SceneLoader.goto_scene("res://game/ui/screens/OptionsMenu.tscn", false)
