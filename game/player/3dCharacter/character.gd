extends CharacterBody3D

@onready var _skin = %SophiaSkin
@onready var _camera = find_child("Camera3D")
var _last_movement_direction := Vector3.BACK
var input_disabled := false
var _is_on_wall := false
var current_car: VehicleBody3D = null

@export_category("Movement")
@export var SPEED = 8.0
@export var SPRINT_MULTIPLIER = 4.0
@export var ACCELERATION = 20.0
@export var JUMP_VELOCITY = 30
@export var ROTATION_SPEED = 12.0

@export_category("Step Climbing")
@export var MAX_STEP_HEIGHT = 0.5
@export var STEP_RAYCAST_DISTANCE = 0.3
@export var STEP_CLIMB_SPEED = 15.0

func _physics_process(delta: float) -> void:
	
	var is_starting_jump = Input.is_action_just_pressed("jump") and (is_on_floor() or _check_wall_collision())
	if is_starting_jump and not input_disabled:
		velocity.y += JUMP_VELOCITY
	
	var is_sprinting = Input.is_action_pressed("sprint") and not input_disabled
	var current_speed = SPEED * (SPRINT_MULTIPLIER if is_sprinting else 1.0)

	var input_dir := Vector2.ZERO
	if not input_disabled:
		input_dir = Input.get_vector("left", "right", "up", "down")
	var forward :Vector3 = _camera.global_basis.z
	var right : Vector3 = _camera.global_basis.x
	
	var move_direction: Vector3 = forward * input_dir.y + right * input_dir.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	if move_direction.length() > 0.2:
		velocity = velocity.move_toward(move_direction*current_speed,ACCELERATION*delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	if not is_on_floor():
		velocity += get_gravity() * 7 * delta
	
	# Automatic step climbing
	if is_on_floor() and move_direction.length() > 0.2:
		_handle_step_climbing(move_direction, delta)

	move_and_slide()
	
	#Skin animation
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction,
		Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, 1)
	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		if velocity.length() > 0.2:
			_skin.move()
		else:
			_skin.idle()


func _handle_step_climbing(move_direction: Vector3, _delta: float) -> void:
	# Raycast forward to detect if there's a step ahead
	var raycast_start = global_position + Vector3.UP * 0.1
	var raycast_end = raycast_start + move_direction * STEP_RAYCAST_DISTANCE
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(raycast_start, raycast_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		# Found an obstacle ahead at chest height
		var _obstacle_point = result.position
		
		# Now raycast downward from slightly ahead to find the top of the step
		var step_check_start = global_position + move_direction * STEP_RAYCAST_DISTANCE + Vector3.UP * MAX_STEP_HEIGHT
		var step_check_end = step_check_start - Vector3.UP * (MAX_STEP_HEIGHT * 2)
		
		query = PhysicsRayQueryParameters3D.create(step_check_start, step_check_end)
		var step_result = space_state.intersect_ray(query)
		
		if step_result:
			# Calculate the height difference
			var ground_level = global_position.y
			var step_top = step_result.position.y
			var step_height = step_top - ground_level
			
			# Only climb if the step is within reasonable height and we're moving toward it
			if step_height > 0.05 and step_height <= MAX_STEP_HEIGHT:
				velocity.y = STEP_CLIMB_SPEED


func _check_wall_collision() -> bool:
	# Raycast in multiple directions around the character to detect walls
	var space_state = get_world_3d().direct_space_state
	var raycast_distance = 0.5  # Distance to check for walls
	var directions = [
		Vector3.RIGHT,
		Vector3.LEFT,
		Vector3.FORWARD,
		Vector3.BACK,
		(Vector3.RIGHT + Vector3.FORWARD).normalized(),
		(Vector3.RIGHT + Vector3.BACK).normalized(),
		(Vector3.LEFT + Vector3.FORWARD).normalized(),
		(Vector3.LEFT + Vector3.BACK).normalized(),
	]
	
	var raycast_start = global_position + Vector3.UP * 0.5
	
	for direction in directions:
		var raycast_end = raycast_start + direction * raycast_distance
		var query = PhysicsRayQueryParameters3D.create(raycast_start, raycast_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			return true
	
	return false


## Called by car entry trigger to enter a car
func enter_car(car: VehicleBody3D) -> void:
	current_car = car
	# The car will handle repositioning the player and disabling collision
	if car.has_method("request_player_entry"):
		car.request_player_entry(self)


## Called by car when player exits - restores player to normal state
func exit_car() -> void:
	current_car = null
	# Player collision and input already restored by car's _exit_car() method
