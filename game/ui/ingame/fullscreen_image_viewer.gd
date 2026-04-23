extends CanvasLayer

@onready var background = %Background
@onready var image_display = %ImageDisplay


func _ready() -> void:
	background.gui_input.connect(_on_gui_input)


func show_image(texture: Texture2D) -> void:
	"""Display an image fullscreen"""
	image_display.texture = texture


func _input(event: InputEvent) -> void:
	"""Close on any input"""
	if event is InputEventMouseButton and event.pressed:
		queue_free()
		get_tree().root.set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		queue_free()
		get_tree().root.set_input_as_handled()


func _on_gui_input(event: InputEvent) -> void:
	"""Close on GUI input"""
	if event is InputEventMouseButton and event.pressed:
		queue_free()
		get_tree().root.set_input_as_handled()
