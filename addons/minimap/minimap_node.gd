@tool
extends SubViewportContainer
class_name MiniMap

var sub_viewport: SubViewport
var border: Line2D
var placeholder: ColorRect
var marker: Sprite2D
var marker_pointer: Sprite2D
@onready var sub_viewport_container: SubViewportContainer = $"."

var camera_3d: Camera3D
var quest_markers: Dictionary = {}  # quest_id -> Sprite2D
@export var zoom: float = 0.5:
	set(value):
		zoom = value
		if camera_3d:
			camera_3d.size = zoom * 100.0

@export var window_size: Vector2i = Vector2i(256, 128):
	set(value):
		window_size = value
		if sub_viewport:
			sub_viewport.size = window_size
			update_border()

@export var target: Node3D
@export var hide_marker: bool = false
@export var marker_image: Texture2D:
	set(value):
		marker_image = value
		if marker:
			marker.texture = marker_image
@export var quest_marker_image: Texture2D:
	set(value):
		quest_marker_image = value
		for quest_id in quest_markers:
			var marker_data = quest_markers[quest_id]
			var quest_marker = marker_data["marker"]
			quest_marker.texture = quest_marker_image

@export var quest_marker_pointer_image: Texture2D:
	set(value):
		quest_marker_pointer_image = value
		for quest_id in quest_markers:
			var marker_data = quest_markers[quest_id]
			if "pointer" in marker_data and marker_data["pointer"]:
				marker_data["pointer"].texture = quest_marker_pointer_image

@export var marker_scale: Vector2 = Vector2(1, 1):
	set(value):
		marker_scale = value
		if marker:
			marker.scale = marker_scale

@export var pointer_scale: Vector2 = Vector2(1, 1):
	set(value):
		pointer_scale = value
		for quest_id in quest_markers:
			var marker_data = quest_markers[quest_id]
			if "pointer" in marker_data and marker_data["pointer"]:
				marker_data["pointer"].scale = pointer_scale

@export var border_line_color: Color = Color.BLACK:
	set(value):
		border_line_color = value
		if border:
			border.default_color = border_line_color

@export var frame_image: PackedScene:
	set(value):
		frame_image = value
		if frame_image:
			var frame_instance = frame_image.instantiate()
			if frame_instance is NinePatchRect and sub_viewport:
				add_child(frame_instance)
				frame_instance.custom_minimum_size = Vector2(sub_viewport.size.x, sub_viewport.size.y)

func setup():
	if sub_viewport: return

	sub_viewport = SubViewport.new()
	add_child(sub_viewport)

	marker = Sprite2D.new()
	add_child(marker)
	
	marker_pointer = Sprite2D.new()
	add_child(marker_pointer)
	
	camera_3d = Camera3D.new()
	camera_3d.position.y = 100
	camera_3d.rotation.x = -PI / 2
	add_child(camera_3d)

	border = Line2D.new()
	add_child(border)

	placeholder = ColorRect.new()
	add_child(placeholder)

func _enter_tree():
	if Engine.is_editor_hint():
		setup()

func _ready() -> void:
	setup()

	sub_viewport.size = window_size
	
	if camera_3d and camera_3d.get_parent() != sub_viewport:
		camera_3d.reparent(sub_viewport)
	
	marker.texture = marker_image
	if marker_scale and marker_scale != Vector2.ZERO:
		marker.scale = marker_scale
	
	if marker_pointer and quest_marker_pointer_image:
		marker_pointer.texture = quest_marker_pointer_image
		marker_pointer.scale = pointer_scale
		marker_pointer.z_index = 3
	
	placeholder.hide()

	# Setup Camera3D for top-down orthographic view
	if camera_3d:
		camera_3d.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera_3d.size = zoom * 100.0

	border.default_color = border_line_color
	border.add_point(Vector2(2.5, 2.5))
	border.add_point(Vector2(sub_viewport.size.x - 2.5, 2.5))
	border.add_point(Vector2(sub_viewport.size.x - 2.5, sub_viewport.size.y - 2.5))
	border.add_point(Vector2(2.5, sub_viewport.size.y - 2.5))
	border.add_point(Vector2(2.5, 2.5))

	marker.position = Vector2(sub_viewport.size.x / 2, sub_viewport.size.y / 2)

	if frame_image:
		var frame_instance = frame_image.instantiate()
		if frame_instance is NinePatchRect:
			add_child(frame_instance)
			frame_instance.custom_minimum_size = Vector2(sub_viewport.size.x, sub_viewport.size.y)

	sub_viewport.world_3d = get_tree().root.world_3d

func update_border():
	if not border: return

	border.clear_points()
	border.default_color = border_line_color

	border.add_point(Vector2(2.5, 2.5))
	border.add_point(Vector2(window_size.x - 2.5, 2.5))
	border.add_point(Vector2(window_size.x - 2.5, window_size.y - 2.5))
	border.add_point(Vector2(2.5, window_size.y - 2.5))
	border.add_point(Vector2(2.5, 2.5))

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	if target and camera_3d:
		camera_3d.position.x = target.position.x
		camera_3d.position.z = target.position.z
	
	# Update all quest marker positions
	_update_quest_markers()
	
	_update_player_marker_pointer()


func add_quest_marker(quest_id: String, world_position: Vector3, marker_color: Color = Color.WHITE) -> void:
	"""Add a quest marker to the minimap at the given world position"""
	if quest_id in quest_markers:
		return  # Marker already exists
	
	var quest_marker = Sprite2D.new()
	quest_marker.texture = quest_marker_image
	quest_marker.scale = marker_scale
	quest_marker.z_index = 2
	quest_marker.self_modulate = marker_color
	add_child(quest_marker)
	
	# Create pointer sprite for out-of-bounds marker indication
	var pointer = Sprite2D.new()
	pointer.texture = quest_marker_pointer_image
	pointer.scale = pointer_scale
	pointer.z_index = 3
	pointer.visible = false  # Initially hidden until marker goes out of bounds
	pointer.self_modulate = marker_color
	add_child(pointer)
	
	print("Added quest marker for quest_id: %s at world position: %s" % [quest_id, world_position])
	
	quest_markers[quest_id] = {
		"marker": quest_marker,
		"pointer": pointer,
		"world_position": world_position,
		"color": marker_color
	}


func remove_quest_marker(quest_id: String) -> void:
	"""Remove a quest marker from the minimap"""
	if quest_id not in quest_markers:
		return
	
	print("Removing quest marker for quest_id: %s" % quest_id)
	var marker_data = quest_markers[quest_id]
	marker_data["marker"].queue_free()
	if "pointer" in marker_data and marker_data["pointer"]:
		marker_data["pointer"].queue_free()
	quest_markers.erase(quest_id)


func _update_quest_markers() -> void:
	"""Update positions of all quest markers based on camera offset"""
	if not camera_3d or not target:
		return
	
	for quest_id in quest_markers:
		var marker_data = quest_markers[quest_id]
		var quest_marker = marker_data["marker"]
		var pointer = marker_data["pointer"]
		var world_pos = marker_data["world_position"]
		
		# Convert world position to minimap position
		var minimap_pos = _world_to_minimap_position(world_pos)
		
		# Check if marker is out of bounds
		var is_out_of_bounds = _is_out_of_bounds(minimap_pos)
		
		# Clamp to bounds if out of minimap
		var clamped_pos = _clamp_to_minimap_bounds(minimap_pos)
		quest_marker.position = clamped_pos
		
		# Update pointer visibility and rotation
		if is_out_of_bounds and pointer:
			pointer.visible = true
			pointer.position = clamped_pos
			pointer.rotation = _calculate_pointer_angle(world_pos)
			if quest_marker:
				quest_marker.visible = false
		elif pointer:
			pointer.visible = false
			if quest_marker:
				quest_marker.visible = true


func _calculate_pointer_angle(world_pos: Vector3) -> float:
	if not target:
		return 0.0
	
	# Calculate offset from target position
	var offset = world_pos - target.global_position
	
	# Calculate angle using atan2 (returns 0 pointing right, increases counter-clockwise)
	var angle = atan2(offset.z, offset.x)
	
	# Apply 45 degree offset since pointer texture points to top-left by default
	var offset_radians = PI*3.0 / 4.0
	
	return angle + offset_radians


func _world_to_minimap_position(world_pos: Vector3) -> Vector2:
	"""Convert a 3D world position to 2D minimap coordinates"""
	if not camera_3d or not target:
		return Vector2.ZERO
	
	# Calculate offset from camera center (target)
	var offset = world_pos - target.global_position
	
	# Convert to minimap space based on zoom
	var minimap_x = (offset.x / (zoom * 100.0)) * window_size.x
	var minimap_y = (offset.z / (zoom * 100.0)) * window_size.y
	
	# Center in minimap
	var center_x = window_size.x / 2.0
	var center_y = window_size.y / 2.0
	
	return Vector2(center_x + minimap_x, center_y + minimap_y)


func _is_out_of_bounds(minimap_pos: Vector2) -> bool:
	"""Check if a minimap position is outside the visible bounds"""
	var margin = 10.0  # Distance from edge
	var min_x = margin
	var max_x = window_size.x - margin
	var min_y = margin
	var max_y = window_size.y - margin
	
	return minimap_pos.x < min_x or minimap_pos.x > max_x or \
		   minimap_pos.y < min_y or minimap_pos.y > max_y


func _clamp_to_minimap_bounds(minimap_pos: Vector2) -> Vector2:
	"""Clamp position to minimap bounds, placing out-of-bounds markers on the edge"""
	var margin = 10.0  # Distance from edge
	var min_x = margin
	var max_x = window_size.x - margin
	var min_y = margin
	var max_y = window_size.y - margin
	
	# If within bounds, return as-is
	if minimap_pos.x >= min_x and minimap_pos.x <= max_x and \
	   minimap_pos.y >= min_y and minimap_pos.y <= max_y:
		return minimap_pos

	# Simple clamp to bounds
	var clamped_x = clamp(minimap_pos.x, min_x, max_x)
	var clamped_y = clamp(minimap_pos.y, min_y, max_y)
	
	return Vector2(clamped_x, clamped_y)


func _update_player_marker_pointer() -> void:
	"""Update player marker pointer rotation based on camera viewing direction"""
	
	var scene_root = get_parent().get_parent().get_parent()
	if not scene_root:
		return

	var player = scene_root.get_node_or_null("Player")
	if not player:
		return
	
	# Get the camera from the player
	var camera = player._camera as Camera3D
	if not camera:
		return
	
	# Get camera's forward direction (negative Z axis in Godot)
	var forward = -camera.global_transform.basis.z
	
	# Calculate angle using atan2 (X for horizontal, Z for depth)
	var angle = atan2(forward.x, forward.z)
	
	# Apply 45 degree offset since pointer texture points to top-left by default
	var offset_radians = -PI / 4.0
	
	marker.rotation = angle + offset_radians
