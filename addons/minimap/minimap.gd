extends SubViewportContainer

@onready var sub_viewport: SubViewport = %SubViewport
@onready var border: Line2D = %border
@onready var placeholder: ColorRect = %placeholder
@onready var marker: Sprite2D = %marker
@onready var sub_viewport_container: SubViewportContainer = $"."

@export var camera_3d: Camera3D
@export var zoom: float = 0.5
@export var target: Node3D
@export var hide_marker: bool = false
@export var marker_image: Texture2D
@export var window_size: Vector2i = Vector2i(256, 128)
@export var border_line_color: Color = Color.BLACK
@export var frame_image: PackedScene

func _ready() -> void:
	if hide_marker:
		marker.hide()
	
	sub_viewport.size = window_size
	
	# Add the exported camera to the viewport
	if camera_3d and camera_3d.get_parent() != sub_viewport:
		camera_3d.reparent(sub_viewport)
	
	marker.texture = marker_image
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

func _process(delta: float) -> void:
	if target and camera_3d:
		# Track target XZ position, keep camera at fixed height
		camera_3d.position.x = target.position.x
		camera_3d.position.z = target.position.z
