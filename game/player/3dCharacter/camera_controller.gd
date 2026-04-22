extends Node3D

var parent
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Camera Controller
	parent = get_parent_node_3d()
	position = lerp(position, parent.position, 0.02)
	var current_quat = Quaternion.from_euler(rotation)
	var target_quat = Quaternion.from_euler(parent.rotation)
	rotation = current_quat.slerp(target_quat, 0.1).get_euler()
	pass
