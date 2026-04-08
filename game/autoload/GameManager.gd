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
		"skippable": true
	},
	"quest_1": {
		"id": "quest_1",
		"name": "Alexander Nevsky Cathedral",
		"character": "guide1",
		"dialog_id": "quest_1",
	},
	"quest_2": {
		"id": "quest_2",
		"name": "Toompea Castle",
		"character": "guide2",
		"dialog_id": "quest_2",
	},
	"quest_3": {
		"id": "quest_3",
		"name": "Kiek in de Kök",
		"character": "guide3",
		"dialog_id": "quest_3",
	},
	"quest_4": {
		"id": "quest_4",
		"name": "Tallinn Town Hall",
		"character": "guide4",
		"dialog_id": "quest_4",
	},
	"quest_5": {
		"id": "quest_5",
		"name": "St. Olaf Church",
		"character": "guide5",
		"dialog_id": "quest_5",
	}
}

var quest_sequence = ["tutorial", "quest_1", "quest_2", "quest_3", "quest_4", "quest_5"]
var current_quest_index = 0
var auto_save_timer: Timer

func _ready():
	# Wait for DialogueManager to initialize
	if not DialogueManager.is_node_ready():
		await DialogueManager.ready
	
	# Connect to DialogueQuest signals
	if DialogueQuest:
		DialogueQuest.Signals.dialogue_ended.connect(_on_dialogue_ended)
	
	print("GameManager initialized")

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

func skip_tutorial():
	"""Skip the tutorial quest"""
	SaveData.set_data("tutorial_skipped", true)
	advance_quest()

func _on_dialogue_ended(dialogue_id: String):
	"""Called when DialogueQuest finishes a dialogue"""
	var active_quest = get_active_quest()
	if active_quest.is_empty():
		return
	
	# If the ended dialogue matches the active quest's dialog, advance
	if dialogue_id == active_quest.get("dialog_id"):
		advance_quest()
		print("Quest dialogue completed: %s" % dialogue_id)
