extends Node

@export var speed: float = 0.05  # Time delay between letters

var messages: Array = [
	"> A WILD DUNGEON GOBLIN APPEARED!",
	"> CHOOSE DICE TO ROLL..."
]  
var message_index: int = 0
var roll_message_label: Label

func _ready() -> void:
	print("battle.gd script is running!")

	# Print all child nodes to debug
	print("Listing all child nodes of Battle:")
	for child in get_children():
		print(" -", child.name)

	# Attempt to get the Roll Message label
	roll_message_label = $'Roll Message'  

	if roll_message_label == null:
		print("ERROR: 'Roll Message' label still not found! Check scene structure.")
		return

	print("SUCCESS: Found 'Roll Message' label!")
	roll_message_label.visible = true
	roll_message_label.text = ""  # Start empty

	start_typing()

func start_typing() -> void:
	if message_index >= messages.size():
		return

	var current_text = ""  
	var full_text = messages[message_index]
	print("Typing message:", full_text)

	for i in range(full_text.length()):
		current_text += full_text[i]  
		roll_message_label.text = current_text
		await get_tree().create_timer(speed).timeout  

	await get_tree().create_timer(1.0).timeout  # Small delay before switching text

	message_index += 1
	if message_index < messages.size():
		roll_message_label.text = ""  # Clear text before starting next message
		start_typing()
