extends Node3D

@export var collectible_id: String
@export var image: Texture = null

@onready var planeMaterial: StandardMaterial3D = %MeshInstance3D.mesh.surface_get_material(0) as StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if image:
		planeMaterial.albedo_texture = image

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
