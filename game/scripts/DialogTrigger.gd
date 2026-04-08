extends Area3D
class_name DialogTrigger

@export var quest_id: String = ""
@export var character_name: String = ""
@export var trigger_once: bool = true

var dialogue_completed = false
var player_in_range = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("DialogTrigger ready for quest: %s" % quest_id)
		
func _on_body_entered(body: Node3D) -> void:
	if body is VehicleBody3D or body.name.to_lower().contains("car"):
		player_in_range = true
		_trigger_dialogue()

func _on_body_exited(body: Node3D):
	"""When player car leaves trigger range"""
	if body is VehicleBody3D or body.name.to_lower().contains("car"):
		player_in_range = false
		reset_trigger()
		if dialogue_completed:
			GameManager.advance_quest()
		print("Player left dialogue trigger area for quest: %s" % quest_id)

func _trigger_dialogue():
	"""Trigger dialogue if conditions are met"""
	if dialogue_completed and trigger_once:
		return
	
	# Check if this is the active quest
	var active_quest = GameManager.get_active_quest()
	if active_quest.is_empty() or active_quest.get("id") != quest_id:
		print("DialogTrigger: quest %s is not active (active: %s)" % [quest_id, active_quest.get("id", "none")])
		return
	
	# Start the dialogue
	var dialog_id = active_quest.get("dialog_id", "")
	if not dialog_id.is_empty():
		print("Starting dialogue via DialogueManager: %s" % dialog_id)
		if DialogueManager:
			DialogueManager.play_dialogue(dialog_id)
		dialogue_completed = true
	else:
		print("DialogTrigger error: missing dialog_id in quest")

func reset_trigger():
	"""Reset trigger to allow dialogue to play again"""
	if DialogueManager:
		DialogueManager.stop_dialogue()
	else:
		print("Missing DialogueManager autoload, cannot stop dialogue")
