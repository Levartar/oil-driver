extends Control

@onready var background = %Background
@onready var image_display = %ImageDisplay
var closeable = true


func _ready() -> void:
	background.gui_input.connect(_on_gui_input)


func show_image(texture: Texture2D) -> void:
	"""Display an image fullscreen"""
	image_display.texture = texture


func _input(event: InputEvent) -> void:
	"""Close on any input"""
	if event is InputEventMouseButton and event.pressed:
		close_viewer()
		get_tree().root.set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		close_viewer()
		get_tree().root.set_input_as_handled()


func _on_gui_input(event: InputEvent) -> void:
	"""Close on GUI input"""
	if event is InputEventMouseButton and event.pressed:
		close_viewer()
		get_tree().root.set_input_as_handled()

func close_viewer() -> void:
	"""Close the fullscreen viewer"""
	if closeable:
		queue_free()
