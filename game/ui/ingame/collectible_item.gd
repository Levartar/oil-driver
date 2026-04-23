extends PanelContainer

@onready var image_rect = %CollectibleImage
@onready var description_label: RichTextLabel = %CollectibleDescription

var collectible_id: String
var collectible_data: Dictionary


func _ready() -> void:
	gui_input.connect(_on_gui_input)
		# If collectible_id was set before ready, load the data now
	if collectible_id:
		_load_collectible_data()


func set_collectible_data(id: String) -> void:
	"""Set the collectible data to display"""
	collectible_id = id
	
	# If already in scene tree, load data immediately
	if is_node_ready():
		_load_collectible_data()


func _load_collectible_data() -> void:
	# Try to find collectible data from scene instances
	var collectibles = SaveData.get_data("collected_collectibles", [])
	for collectible in collectibles:
		if collectible.get("id") == collectible_id:
			collectible_data = collectible
			break
	
	# Update UI
	if image_rect and collectible_data.get("image"):
		image_rect.texture = collectible_data["image"]
	
	if description_label and collectible_data.get("description"):
		description_label.text = collectible_data["description"]

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_show_fullscreen_image()


func _show_fullscreen_image() -> void:
	if not collectible_data.get("image"):
		return
	
	var fullscreen_viewer = load("res://game/ui/ingame/FullscreenImageViewer.tscn").instantiate()
	get_tree().root.add_child(fullscreen_viewer)
	fullscreen_viewer.show_image(collectible_data["image"])
