extends CanvasLayer
## Manages dialogue display using DialogueQuest addon
## This node is a CanvasLayer parent for the dialogue system components

var dialogue_player: DQDialoguePlayer
var dialogue_box: DQDialogueBox
var choice_menu: DQChoiceMenu

var dialogue_player_scene = preload("res://addons/dialogue_quest/prefabs/systems/dqd/dialogue_player.tscn")
var dialogue_box_scene = preload("res://addons/dialogue_quest/prefabs/ui/dialogue/components/dialogue_box/dialogue_box.tscn")
var choice_menu_scene = preload("res://addons/dialogue_quest/prefabs/ui/dialogue/components/choice_menu/choice_menu.tscn")

func _ready():
	layer = 10  # Ensure dialogue is on top
	_setup_dialogue_system()
	print("DialogueManager initialized with proper scene hierarchy")

func _setup_dialogue_system():
	"""Initialize the dialogue system with proper scene hierarchy"""
	# Instantiate dialogue player from prefab
	dialogue_player = dialogue_player_scene.instantiate()
	add_child(dialogue_player)
	
	# Instantiate UI components
	dialogue_box = dialogue_box_scene.instantiate()
	add_child(dialogue_box)
	
	choice_menu = choice_menu_scene.instantiate()
	add_child(choice_menu)
	
	# Wait for all nodes to be ready
	await get_tree().process_frame
	
	# Assign UI components to dialogue player
	dialogue_player.dialogue_box = dialogue_box
	dialogue_player.choice_menu = choice_menu
	visible = false  # Start hidden until dialogue is played
	
	print("Dialogue system components configured")

func play_dialogue(dialogue_id: String):
	"""Play a dialogue by full path"""

	if not dialogue_player:
		print("DialogueManager: dialogue_player not initialized")
		return
	
	dialogue_player.play("%s.dqd" % dialogue_id)
	visible = true

func stop_dialogue():
	"""Stop the current dialogue"""
	if dialogue_player:
		dialogue_player.stop()
		visible = false
		print("Dialogue stopped")

func is_playing() -> bool:
	"""Check if a dialogue is currently playing"""
	if not dialogue_player:
		return false
	return dialogue_player.current_dialogue != ""
