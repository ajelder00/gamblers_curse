extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the button's pressed signal to the function
	pressed.connect(_on_button_pressed)

# Function that will be called when the button is pressed
func _on_button_pressed() -> void:
	# Hide the parent of the button
	get_parent().visible = false
