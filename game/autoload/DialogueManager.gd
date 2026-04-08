extends CanvasLayer
## Manages dialogue display using DialogueQuest addon
## This node is a CanvasLayer parent for the dialogue system components

var dialog_player: DQDialoguePlayer
var dialog_box: DQDialogueBox
var choice_menu: DQChoiceMenu

var dialog_player_scene = preload("res://addons/dialogue_quest/prefabs/systems/dqd/dialogue_player.tscn")
var dialog_box_scene = preload("res://addons/dialogue_quest/prefabs/ui/dialogue/components/dialogue_box/dialogue_box.tscn")
var choice_menu_scene = preload("res://addons/dialogue_quest/prefabs/ui/dialogue/components/choice_menu/choice_menu.tscn")

func _ready():
	layer = 10  # Ensure dialogue is on top
	_setup_dialog_system()
	print("DialogManager initialized with proper scene hierarchy")

func _setup_dialog_system():
	"""Initialize the dialog system with proper scene hierarchy"""
	# Instantiate dialogue player from prefab
	dialog_player = dialog_player_scene.instantiate()
	add_child(dialog_player)
	
	# Instantiate UI components
	dialog_box = dialog_box_scene.instantiate()
	add_child(dialog_box)
	
	choice_menu = choice_menu_scene.instantiate()
	add_child(choice_menu)
	
	# Wait for all nodes to be ready
	await get_tree().process_frame
	
	# Assign UI components to dialogue player
	dialog_player.dialogue_box = dialog_box
	dialog_player.choice_menu = choice_menu
	visible = false  # Start hidden until dialogue is played
	
	print("Dialogue system components configured")

func play_dialog(dialogue_id: String):
	"""Play a dialogue by full path"""

	if not dialog_player:
		print("DialogueManager: dialogue_player not initialized")
		return
	
	dialog_player.play("%s.dqd" % dialogue_id)
	visible = true

func stop_dialog():
	"""Stop the current dialogue"""
	if dialog_player:
		dialog_player.stop()
		visible = false
		print("Dialogue stopped")

func is_playing() -> bool:
	"""Check if a dialogue is currently playing"""
	if not dialog_player:
		return false
	return dialog_player.current_dialogue != ""
