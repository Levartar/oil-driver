extends CharacterBody3D

@onready var _skin = $character

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("right", "left", "down", "up")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		#Skin animation
		var target_angle := Vector3.BACK.signed_angle_to(direction,Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, 10*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# Camera Controller
	$CameraController.position = lerp($CameraController.position, position, 0.02)
	var current_quat = Quaternion.from_euler($CameraController.rotation)
	var target_quat = Quaternion.from_euler(rotation)
	$CameraController.rotation = current_quat.slerp(target_quat, 0.1).get_euler()
