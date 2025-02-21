extends Label
@onready var parent = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if parent == null:
		print("Error! parent is Null")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if parent!= null:
		self.text = "Health: " + str(parent.health)
	else:
		self.text = "Health: N/A"
