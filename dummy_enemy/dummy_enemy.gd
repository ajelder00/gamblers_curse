extends Node2D
var health = 90

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func hit():
	var damage = randi_range(0,9)
	return damage

func get_hit(enemy_damage):
	self.health -= enemy_damage
	if self.health < 0:
		self.health = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if health == 0:
		self.rotation_degrees = 90
