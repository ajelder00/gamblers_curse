extends Node2D
@onready var parent = get_parent()
var health = 100
signal attack_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func hit():
	var damage = randi_range(0,10)
	return damage

func get_hit(enemy_damage):
	self.health -= enemy_damage
	if self.health < 0:
		self.health = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	attack_signal.emit
