extends Label

func _process(delta: float) -> void:
	text = "Attempt #" + str(Global.attempts)
