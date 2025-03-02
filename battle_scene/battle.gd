extends Node

@export var speed: float = 0.05  # Time delay between letters

var messages: Array = [
	"> A WILD DUNGEON GOBLIN APPEARED!",
	"> CHOOSE DICE TO ROLL..."
]  
var message_index: int = 0
var roll_message_label: Label
var player_health_label: Label
var player_health_bar: ColorRect
var max_health: float = 100.0  # Adjust based on your game

func _ready() -> void:
	print("battle.gd script is running!")

	# Debug: Print all child nodes
	print("Listing all child nodes of Battle:")
	for child in get_children():
		print(" -", child.name)

	# Get UI elements
	roll_message_label = $'Roll Message'  
	player_health_label = $'PlayerHealthNum'
	player_health_bar = $'PlayerHealth'

	# Check if elements are found
	if roll_message_label == null:
		print("ERROR: 'Roll Message' label not found!")
	if player_health_label == null:
		print("ERROR: 'PlayerHealthNum' label not found!")
	if player_health_bar == null:
		print("ERROR: 'PlayerHealth' bar not found!")

	# Start the message typing effect
	if roll_message_label:
		roll_message_label.visible = true
		roll_message_label.text = ""  # Start empty
		start_typing()

	# Update health display initially
	update_health_display()

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

func update_health_display() -> void:
	if player_health_label and player_health_bar:
		var player_health = Global.player_health  # Get global health variable
		player_health_label.text = str(player_health) + " HP"

		# Ensure the parent is a Control node to get proper width
		var parent_control = player_health_bar.get_parent() as Control
		if parent_control:
			var max_width = parent_control.get_rect().size.x  # Get full width
			var health_ratio = clamp(player_health / max_health, 0.0, 1.0)

			# Adjust health bar width from right to left
			player_health_bar.set_size(Vector2(max_width * health_ratio, player_health_bar.get_rect().size.y))
