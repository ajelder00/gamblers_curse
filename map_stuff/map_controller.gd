extends Node2D
@onready var map = $Map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("child_entered_tree", _on_child_added)

func _on_child_added(child) -> void:
	child.tree_exited.connect(_on_child_freed)
	
func _on_child_freed() -> void:
	map.show_map()
