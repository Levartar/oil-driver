extends Area3D
class_name DialogTrigger

@export var quest_id: String = ""
@export var character_name: String = ""
@export var trigger_once: bool = true

var dialog_completed = false
var player_in_range = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("DialogTrigger ready for quest: %s" % quest_id)
		
func _on_body_entered(body: Node3D) -> void:
	if body is VehicleBody3D or body.name.to_lower().contains("car"):
		player_in_range = true
		_trigger_dialog()

func _on_body_exited(body: Node3D):
	"""When player car leaves trigger range"""
	if body is VehicleBody3D or body.name.to_lower().contains("car"):
		player_in_range = false
		reset_trigger()
		if dialog_completed:
			GameManager.advance_quest()
		print("Player left dialog trigger area for quest: %s" % quest_id)

func _trigger_dialog():
	"""Trigger dialogue if conditions are met"""
	if dialog_completed and trigger_once:
		return
	
	# Check if this is the active quest
	var active_quest = GameManager.get_active_quest()
	if active_quest.is_empty() or active_quest.get("id") != quest_id:
		print("DialogTrigger: quest %s is not active (active: %s)" % [quest_id, active_quest.get("id", "none")])
		return
	
	# Start the dialogue
	var dialog_id = active_quest.get("dialog_id", "")
	if not dialog_id.is_empty():
		print("Starting dialog via DialogManager: %s" % dialog_id)
		if DialogManager:
			DialogManager.play_dialog(dialog_id)
		dialog_completed = true
	else:
		print("DialogTrigger error: missing dialog_id in quest")

func reset_trigger():
	"""Reset trigger to allow dialogue to play again"""
	if DialogManager:
		DialogManager.stop_dialog()
	else:
		print("Missing DialogManager autoload, cannot stop dialog")