extends Sprite2D

var speed: float = 25.00
var direction: Vector2 = Vector2(1, 1).normalized()
var time_elapsed: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if time_elapsed < 7.0:
		position += direction * speed * delta
		time_elapsed += delta
