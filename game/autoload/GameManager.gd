extends Node

signal quest_started(quest_id: String)
signal quest_progressed(quest_id: String)
signal quest_completed(quest_id: String)

var quests = {
	"tutorial": {
		"id": "tutorial",
		"name": "Tutorial",
		"character": "tutorial_guide",
		"dialog_id": "tutorial_wasd",
		"description": "Learn how to move your vehicle using WASD keys.",
	},
	"quest_1": {
		"id": "quest_1",
		"name": "Karu 17",
		"character": "guide1",
		"dialog_id": "quest_1",
		"description": "Visit the Karu Dormitory and speak with the guide.",
	},
	"quest_2": {
		"id": "quest_2",
		"name": "Tallinn University",
		"character": "guide2",
		"dialog_id": "quest_2",
		"description": "Visit the Tallinn University and speak with the guide.",
	},
	"quest_3": {
		"id": "quest_3",
		"name": "R-Kiosk",
		"character": "guide3",
		"dialog_id": "quest_3",
		"description": "Visit the R-Kiosk and speak with the guide.",
	},
	"quest_4": {
		"id": "quest_4",
		"name": "Ulikool Tram Stop",
		"character": "guide4",
		"dialog_id": "quest_4",
		"description": "Visit the Ulikool Tram Stop and speak with the guide.",
	},
	"quest_5": {
		"id": "quest_5",
		"name": "Linnahall",
		"character": "guide5",
		"dialog_id": "quest_5",
		"description": "Visit Linnahall and speak with the guide.",
	}
}

var quest_sequence = ["tutorial", "quest_1", "quest_2", "quest_3", "quest_4", "quest_5"]
var current_quest_index = 0

func _ready():
	# Wait for DialogManager to initialize
	if not DialogManager.is_node_ready():
		await DialogManager.ready
	
	# Connect to DialogueQuest signals
	if DialogueQuest:
		DialogueQuest.Signals.dialogue_ended.connect(_on_dialog_ended)
	
func _restore_quest_progress():
	"""Restore quest progress from SaveData when loading a save"""
	var active_quest = SaveData.get_data("active_quest_id")
	var completed_quests = SaveData.get_data("completed_quests", [])
	
	if active_quest in quests:
		current_quest_index = quest_sequence.find(active_quest)
	
	print("Restored quest progress: Active=%s, Completed=%d" % [active_quest, completed_quests.size()])

func get_active_quest() -> Dictionary:
	"""Get the currently active quest"""
	if current_quest_index < quest_sequence.size():
		var quest_id = quest_sequence[current_quest_index]
		return quests[quest_id]
	return {}

func get_completed_quests() -> Array:
	"""Get all completed quests as an array of quest dictionaries"""
	var completed_quests = SaveData.get_data("completed_quests", [])
	var result = []
	for quest_id in completed_quests:
		if quest_id in quests:
			result.append(quests[quest_id])
	return result

func get_quest_visibility_list() -> Array:
	"""Get list of quests to display (active + completed, not pending)"""
	var result = []
	var active_quest_id = SaveData.get_data("active_quest_id", "")
	var completed_quests = SaveData.get_data("completed_quests", [])
	
	# Add active quest first
	if active_quest_id in quests:
		var active_quest = quests[active_quest_id].duplicate()
		active_quest["completed"] = false
		result.append(active_quest)
	
	# Add completed quests
	for quest_id in completed_quests:
		if quest_id in quests:
			var completed_quest = quests[quest_id].duplicate()
			completed_quest["completed"] = true
			result.append(completed_quest)
	
	return result

func advance_quest():
	"""Mark current quest as complete and advance to next"""
	var active_quest_id = SaveData.get_data("active_quest_id")
	var completed_quests = SaveData.get_data("completed_quests", [])
	
	if active_quest_id not in completed_quests:
		completed_quests.append(active_quest_id)
		SaveData.set_data("completed_quests", completed_quests)
	
	emit_signal("quest_completed", active_quest_id)
	
	# Move to next quest
	current_quest_index += 1
	if current_quest_index < quest_sequence.size():
		var next_quest_id = quest_sequence[current_quest_index]
		SaveData.set_data("active_quest_id", next_quest_id)
		emit_signal("quest_started", next_quest_id)
		print("Advanced to quest: %s" % next_quest_id)
	else:
		print("All quests completed!")
	
	SaveData.save_game()

func _on_dialog_ended(dialog_id: String):
	"""Called when DialogueQuest finishes a dialogue"""
	print("Dialog ended: %s" % dialog_id)
	var active_quest = get_active_quest()
	if active_quest.is_empty():
		return
	
	# If the ended dialogue matches the active quest's dialog, advance
	var dialog_base = dialog_id.trim_suffix(".dqd")
	if dialog_base == active_quest.get("dialog_id"):
		if dialog_base == "quest_1":
			_lerp_fog_to_bright()
		
		advance_quest()
		print("Quest dialog completed: %s" % dialog_base)

func new_game():
	current_quest_index = 0
	SaveData.delete_save()

func get_world_environment() -> WorldEnvironment:
	"""Helper to get the current level's WorldEnvironment node"""
	var world_env = get_tree().get_first_node_in_group("world_environment") as WorldEnvironment
	
	if not world_env:
		# Try to find WorldEnvironment by name if not in group
		world_env = get_tree().root.find_child("WorldEnvironment", true, false) as WorldEnvironment
	
	return world_env

func fog_dark() -> void:
	var env = get_world_environment().environment
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	env.fog_light_color = Color(0.3, 0.3, 0.3)  # Dark grey
	env.fog_light_energy = 0.66
	env.fog_density = 0.1
	env.fog_sky_affect = 1.0

func fog_bright() -> void:
	var env = get_world_environment().environment
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	env.fog_light_color = Color(0, 0.59, 0.71)  # Bright blue
	env.fog_light_energy = 0.66
	env.fog_density = 0.01
	env.fog_sky_affect = 0.3


func _lerp_fog_to_bright() -> void:
	"""Smoothly transition fog from dark to bright using lerp"""
	var world_env = get_world_environment()
	if not world_env or not world_env.environment:
		return
	
	var env = world_env.environment
	var duration = 3.0  # seconds
	var elapsed = 0.0
	
	var dark_color = Color(0.3, 0.3, 0.3)
	var bright_color = Color(0, 0.59, 0.71)
	var dark_density = 0.1
	var bright_density = 0.01
	var dark_energy = 0.66
	var bright_energy = 0.66
	
	while elapsed < duration:
		var progress = elapsed / duration
		env.fog_light_color = dark_color.lerp(bright_color, progress)
		env.fog_density = lerp(dark_density, bright_density, progress)
		env.fog_light_energy = lerp(dark_energy, bright_energy, progress)
		env.fog_sky_affect = lerp(1.0, 0.3, progress)
		
		elapsed += get_physics_process_delta_time()
		await get_tree().physics_frame
