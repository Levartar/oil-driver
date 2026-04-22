extends CharacterBody3D

@onready var _skin = $character
@onready var _camera = find_child("Camera3D")

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
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var forward :Vector3 = _camera.global_basis.z
	var right : Vector3 = _camera.global_basis.x
	print("forward and right:", forward, right)
	var move_direction := forward * input_dir.y + right * input_dir.x
	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
		#Skin animation
		var target_angle := Vector3.BACK.signed_angle_to(move_direction,Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, 10*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
