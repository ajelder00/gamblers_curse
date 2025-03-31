extends Node2D


func _on_return_to_map_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property($Node, "scale", Vector2(2, 2), 1.0)
