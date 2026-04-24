extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("setting debug:",Settings.get_setting("debug") )
	if Settings.get_setting("debug"):
		%InGameUI.visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
