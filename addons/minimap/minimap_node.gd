@tool
extends SubViewportContainer
class_name MiniMap

var sub_viewport: SubViewport
var border: Line2D
var placeholder: ColorRect
var marker: Sprite2D
@onready var sub_viewport_container: SubViewportContainer = $"."

@export var camera_3d: Camera3D
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

@export var marker_scale: Vector2 = Vector2(1, 1):
	set(value):
		marker_scale = value
		if marker:
			marker.scale = marker_scale

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
	
	# Add the exported camera to the viewport
	if camera_3d and camera_3d.get_parent() != sub_viewport:
		camera_3d.reparent(sub_viewport)
	
	marker.texture = marker_image
	if marker_scale and marker_scale != Vector2.ZERO:
		marker.scale = marker_scale
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
