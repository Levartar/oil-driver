extends VehicleBody3D
@export var MAX_STEER = 0.2
@export var ENGINE_POWER = 4000
@export var EXIT_SEARCH_DISTANCE = 5.0
@export var EXIT_RAYCAST_HEIGHT = 1.0

# Camera view transforms (stored as variables since Transform3D isn't a constant expression)
var isometric_transform: Transform3D 
var third_person_transform: Transform3D

var input_disabled: bool = true
var player_inside: bool = false
var player: CharacterBody3D = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle exit input when player is inside
	if player_inside and Input.is_action_just_pressed("interact"):
		_exit_car()
		return
	
	if not input_disabled and player_inside:
		steering = move_toward(steering, Input.get_axis("right","left")*MAX_STEER,delta*10)
		var engine_multiplier = 1.0
		player.global_position = global_position
		
		# Apply testing acceleration multipliers
		# Not good code. This should be refactored to be cleaner and more maintainable, but it works for now.
		if Settings.get_setting("auto_acceleration", false):
			engine_force = ENGINE_POWER * engine_multiplier
		else:
			engine_force = ENGINE_POWER * Input.get_axis("down","up")
	else:
		engine_force = 0

## Called by CarEntryTrigger when player presses interact in range
func request_player_entry(player_ref: CharacterBody3D) -> void:
	if player_inside:
		return
	
	player = player_ref
	player_inside = true
	input_disabled = false
	
	# Transfer player to car
	player.global_position = global_position
	player.input_disabled = true
	
	# Deactivate player collision/movement
	#if player.has_node("CollisionShape3D"):
	#	player.get_node("CollisionShape3D").disabled = true

## Exit the car and place player at closest valid ground position
func _exit_car() -> void:
	if not player_inside or player == null:
		return
	
	player_inside = false
	input_disabled = true
	
	# Stop the car
	engine_force = 0
	linear_velocity = Vector3.ZERO
	
	# Find closest valid exit position
	var exit_position = _find_exit_position()
	
	# Re-enable player
	if player.has_node("CollisionShape3D"):
		player.get_node("CollisionShape3D").disabled = false
	
	player.global_position = exit_position
	player.input_disabled = false
	player.velocity = Vector3.ZERO
	
	# Notify player of exit
	if player.has_method("exit_car"):
		player.exit_car()
	
	player = null

## Find the closest valid ground position to exit at
func _find_exit_position() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var car_center = global_position
	var best_position = car_center + Vector3.BACK * 2.0  # Fallback position
	var best_distance = EXIT_SEARCH_DISTANCE
	
	# Check multiple directions around the car for valid exit points
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
	
	for direction in directions:
		# Start raycast from above the car
		var raycast_start = car_center + Vector3.UP * EXIT_RAYCAST_HEIGHT
		var raycast_horizontal = raycast_start + direction * EXIT_SEARCH_DISTANCE
		
		# Raycast down from horizontal distance to find ground
		var raycast_end = raycast_horizontal - Vector3.UP * (EXIT_RAYCAST_HEIGHT + 2.0)
		var query = PhysicsRayQueryParameters3D.create(raycast_horizontal, raycast_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			var candidate_position = result.position + Vector3.UP * 0.1  # Slight offset above ground
			var distance_from_car = car_center.distance_to(candidate_position)
			
			# Check if this position is closer and valid
			if distance_from_car < best_distance:
				best_distance = distance_from_car
				best_position = candidate_position
	
	return best_position
