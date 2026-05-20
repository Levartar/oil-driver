extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("setting debug:",Settings.get_setting("debug") )
	if Settings.get_setting("debug"):
		%InGameUI.visible = true
	
	# Connect all DialogTrigger signals to the minimap
	_setup_dialog_trigger_minimap_connections()
	
	# Connect to GameManager's all_quests_completed signal to show poster markers
	if GameManager:
		GameManager.all_quests_completed.connect(_on_all_quests_completed)
		GameManager.collectible_collected.connect(_on_collectible_collected)


func _setup_dialog_trigger_minimap_connections() -> void:
	"""Connect all DialogTrigger signals to the minimap"""
	var minimap = %MiniMap as MiniMap
	if not minimap:
		printerr("PlaytestLevel: MiniMap not found")
		return
	
	# Find all DialogTrigger nodes in the level
	var dialog_triggers = get_tree().get_nodes_in_group("dialog_triggers")
	if dialog_triggers.is_empty():
		# If no group exists, search for all DialogTrigger nodes
		dialog_triggers = _find_all_dialog_triggers(self)
	
	for trigger in dialog_triggers:
		if trigger is DialogTrigger:
			trigger.quest_marker_needed.connect(minimap.add_quest_marker)
			trigger.quest_marker_remove.connect(minimap.remove_quest_marker)


func _on_collectible_collected(collectible_id: String) -> void:
	"""Called when a collectible is collected - remove its marker from minimap"""
	var minimap = %MiniMap as MiniMap
	if minimap:
		minimap.remove_quest_marker(collectible_id)
		print("Removed poster marker for collected collectible: %s" % collectible_id)


func _find_all_dialog_triggers(node: Node) -> Array:
	"""Recursively find all DialogTrigger nodes"""
	var triggers = []
	if node is DialogTrigger:
		triggers.append(node)
	for child in node.get_children():
		triggers += _find_all_dialog_triggers(child)
	return triggers


func _on_all_quests_completed() -> void:
	"""Called when all quests are completed - show all poster markers"""
	print("All quests completed! Showing poster markers...")
	
	var minimap = %MiniMap as MiniMap
	if not minimap:
		printerr("PlaytestLevel: MiniMap not found")
		return
	
	# Find all collectibles in the "collectibles" group
	var collectibles = get_tree().get_nodes_in_group("collectibles")
	var orange_color = Color(1.0, 0.647, 0.0)  # Orange color for poster markers
	
	for collectible in collectibles:
		if collectible.is_in_group("collectibles"):
			# Get collectible_id from the collectible object
			var collectible_id = ""
			if collectible.has_meta("collectible_id"):
				collectible_id = collectible.get_meta("collectible_id")
			elif "collectible_id" in collectible:
				collectible_id = collectible.collectible_id
			
			if collectible_id and not SaveData.has_collectible(collectible_id):
				# Only show marker if not already collected
				var world_pos = collectible.global_position
				minimap.add_quest_marker(collectible_id, world_pos, orange_color)
				print("Added poster marker for: %s at position %s" % [collectible_id, world_pos])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
