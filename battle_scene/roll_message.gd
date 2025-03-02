extends Node

@export var speed: float = 0.05  # Time delay between letters

var messages: Array = [
	"A WILD DUNGEON GOBLIN APPEARED",
	"CHOOSE DICE TO ROLL"
]  
var message_index: int = 0
var roll_message_label: Label

func _ready() -> void:
	print("battle.gd script is running!")
	await get_tree().process_frame  # Ensure the node is fully loaded
	roll_message_label = $RollMessage  # Get the child Label node

	if roll_message_label == null:
		print("ERROR: Roll Message label not found!")
		return

	roll_message_label.visible = true
	roll_message_label.text = ""  # Start empty
	print("Starting typing effect...")
	
	start_typing()

func start_typing() -> void:
	if message_index >= messages.size():
		return

	var current_text = ""  
	var full_text = messages[message_index]  # Get the current message
	print("Typing message:", full_text)

	for i in range(full_text.length()):
		current_text += full_text[i]  
		roll_message_label.text = current_text
		await get_tree().create_timer(speed).timeout  

	await get_tree().create_timer(1.0).timeout  # Small delay before switching text

	message_index += 1
	if message_index < messages.size():  # If there's another message, restart typing
		roll_message_label.text = ""  # Clear text before starting next message
		start_typing()
