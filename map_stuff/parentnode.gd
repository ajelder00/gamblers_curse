extends Node2D
@export var parent_node: Node2D

func get_valid_moves():
	return [parent_node] if parent_node else []
