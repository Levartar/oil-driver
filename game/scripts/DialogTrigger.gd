extends Area3D
class_name DialogTrigger

@export var quest_id: String = ""
@export var character_name: String = ""
@export var trigger_once: bool = false

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
	
	# Start the dialogue
	if not quest_id.is_empty():
		print("Starting dialog via DialogManager: %s" % quest_id)
		if DialogManager:
			DialogManager.play_dialog(quest_id)
		dialog_completed = true
	else:
		print("DialogTrigger error: missing dialog_id in quest")

func reset_trigger():
	"""Reset trigger to allow dialogue to play again"""
	if DialogManager:
		DialogManager.stop_dialog()
	else:
		print("Missing DialogManager autoload, cannot stop dialog")
