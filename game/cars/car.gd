extends VehicleBody3D
@export var MAX_STEER = 0.2
@export var ENGINE_POWER = 4000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
