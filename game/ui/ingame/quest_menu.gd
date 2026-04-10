extends Control

@export var folded = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FoldableContainer.folded = folded
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
