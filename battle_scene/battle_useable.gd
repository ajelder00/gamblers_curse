extends Node
@export var player_template: PackedScene
@export var enemy_template: PackedScene

var player
var enemy
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = player_template.instantiate()
	enemy = enemy_template.instantiate()
	add_child(player)
	add_child(enemy)
	player.attack_signal.connect(_on_player_attack)



func _on_player_attack() -> void:
	if player.health > 0 and enemy.health > 0:
		enemy.get_hit(player.hit())
		player.get_hit(enemy.hit())
	else:
		print("hes already dead...")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
