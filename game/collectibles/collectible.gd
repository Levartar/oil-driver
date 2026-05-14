extends Node3D

@export var collectible_id: String
@export var image: Texture = null
@export var description: String = ""

@onready var planeMaterial: StandardMaterial3D = $MeshInstance3D.mesh.surface_get_material(0) as StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("collectibles")
	if image:
		var unique_material = planeMaterial.duplicate() as StandardMaterial3D
		$MeshInstance3D.set_surface_override_material(0, unique_material)
		unique_material.albedo_texture = image

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func collect_collectible() -> void:
	%Glow.visible = false
	var collectible_data = {
				"id": collectible_id,
				"image": image,
				"description": description
			}
	if GameManager:
		GameManager.collect_collectible(collectible_id,collectible_data)
