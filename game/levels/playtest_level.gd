extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("setting debug:",Settings.get_setting("debug") )
	if Settings.get_setting("debug"):
		%InGameUI.visible = true
	
	# Connect all DialogTrigger signals to the minimap
	_setup_dialog_trigger_minimap_connections()


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


func _find_all_dialog_triggers(node: Node) -> Array:
	"""Recursively find all DialogTrigger nodes"""
	var triggers = []
	if node is DialogTrigger:
		triggers.append(node)
	for child in node.get_children():
		triggers += _find_all_dialog_triggers(child)
	return triggers


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
