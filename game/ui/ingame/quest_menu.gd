extends Control

@export var folded = false

@onready var vbox_container = %QuestVBoxContainer
@onready var bobbing_marker = %QuestBobbingMarker
@onready var template_quest_container = %QuestFoldableContainer
@onready var collectibles_container = %CollectiblesGridContainer

var quest_containers: Array = []
var active_quest_id: String = ""


func _ready() -> void:
	$FoldableContainer.folded = folded

	release_focus()
	
	# Get initial quest state
	active_quest_id = SaveData.get_data("active_quest_id", "")
	
	# Connect to GameManager signals for updates
	if GameManager:
		GameManager.quest_completed.connect(_on_quest_completed)
		GameManager.quest_started.connect(_on_quest_started)
		GameManager.collectible_collected.connect(_on_collectible_collected)
	
	# Initial display
	update_quests_display()
	update_collectibles_display()


func _process(_delta: float) -> void:
	pass


func update_quests_display() -> void:
	"""Update quest display with active and completed quests"""
	# Get quests to display (active + completed)
	var visible_quests = GameManager.get_quest_visibility_list()
	
	if visible_quests.is_empty():
		return
	
	# Ensure we have enough containers
	_ensure_containers(visible_quests.size())
	
	# Populate containers
	for i in range(visible_quests.size()):
		var quest = visible_quests[i]
		var container = quest_containers[i]
		
		# Set title
		container.title = quest["name"]
		
		# Get RichTextLabel and set description
		var rich_text_label = container.find_child("RichTextLabel", true, false) as RichTextLabel
		if rich_text_label:
			rich_text_label.text = quest.get("description", "")
		
		# Apply styling for completed quests
		if quest.get("completed", false):
			_apply_completed_style(container)
		else:
			_apply_active_style(container)
		
		# Show container
		container.show()
	
	# Hide unused containers
	for i in range(visible_quests.size(), quest_containers.size()):
		quest_containers[i].hide()
	
	# Position bobbing marker above active quest
	if quest_containers.size() > 0:
		# Move bobbing marker to be before the first container (active quest)
		vbox_container.move_child(bobbing_marker, 0)
		bobbing_marker.show()
	else:
		bobbing_marker.hide()


func _ensure_containers(count: int) -> void:
	"""Create enough quest containers if needed"""
	while quest_containers.size() < count:
		var new_container = template_quest_container.duplicate()
		new_container.unique_name_in_owner = false
		vbox_container.add_child(new_container)
		quest_containers.append(new_container)
	
	# Hide the template container
	template_quest_container.hide()


func _apply_completed_style(container: Control) -> void:
	"""Apply darker styling to completed quest containers"""
	# Reduce opacity/brightness for completed quests
	container.modulate = Color(0.7, 0.7, 0.7, 1.0)


func _apply_active_style(container: Control) -> void:
	"""Apply normal styling to active quest container"""
	container.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_quest_completed(_quest_id: String) -> void:
	"""Called when a quest is completed"""
	update_quests_display()


func _on_quest_started(quest_id: String) -> void:
	"""Called when a new quest becomes active"""
	active_quest_id = quest_id
	update_quests_display()


func _on_collectible_collected(_collectible_id: String) -> void:
	"""Called when a collectible is collected"""
	update_collectibles_display()


func update_collectibles_display() -> void:
	"""Update collectibles display"""
	if not collectibles_container:
		print("Error: collectibles_container not found");
		return
	
	var collected_ids = GameManager.get_collected_collectibles()
	
	# Clear existing collectibles
	for child in collectibles_container.get_children():
		child.queue_free()
	
	# Add collected collectibles
	for collectible_id in collected_ids:
		var collectible_scene = load("res://game/ui/ingame/CollectibleItem.tscn")
		if collectible_scene:
			var collectible_ui = collectible_scene.instantiate()
			collectible_ui.set_collectible_data(collectible_id)
			collectibles_container.add_child(collectible_ui)

func _input(event: InputEvent) -> void:
	# Don't consume jump input - let it pass to the player
	if event.is_action("jump"):
		get_tree().root.set_input_as_handled()
