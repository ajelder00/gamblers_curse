extends Label

@export var speed: float = 0.05  # Time delay between letters

var messages: Array = []  
var current_text: String = ""
var message_index: int = 0

func _ready() -> void:
	messages = [text, "DUNGEON GOBLIN IS ROLLING..."]  # Store the original and new message
	text = ""  # Start empty
	start_typing()

func start_typing() -> void:
	current_text = ""  
	var full_text = messages[message_index]  # Get the current message
	
	for i in range(full_text.length()):
		current_text += full_text[i]  
		text = current_text
		await get_tree().create_timer(speed).timeout  

	await get_tree().create_timer(1.0).timeout  # Small delay before switching text

	message_index += 1
	if message_index < messages.size():  # If there's another message, restart typing
		text = ""  # Clear text before starting next message
		start_typing()
