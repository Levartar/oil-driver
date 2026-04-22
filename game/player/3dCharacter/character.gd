extends CharacterBody3D

@onready var _skin = %SophiaSkin
@onready var _camera = find_child("Camera3D")
var _last_movement_direction := Vector3.BACK

@export_category("Movement")
@export var SPEED = 8.0
@export var ACCELERATION = 20.0
@export var JUMP_VELOCITY = 30

func _physics_process(delta: float) -> void:	
	var is_starting_jump = Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += JUMP_VELOCITY
		
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var forward :Vector3 = _camera.global_basis.z
	var right : Vector3 = _camera.global_basis.x
	
	var move_direction := forward * input_dir.y + right * input_dir.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	var y_velocity := velocity.y
	#velocity.y = 0.0
	velocity = velocity.move_toward(move_direction*SPEED,ACCELERATION*delta)
	if not is_on_floor():
		velocity += get_gravity()*7 * delta
		
	move_and_slide()
	
	#Skin animation
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction,
		Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, 12*delta)
	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		if velocity.length() > 0.2:
			_skin.move()
		else:
			_skin.idle()
