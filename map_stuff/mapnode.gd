extends Node2D
@export var children_nodes: Array[Node2D]

func get_valid_moves():
	return children_nodes
