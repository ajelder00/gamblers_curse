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
		var player_sprite = player.get_node("AnimatedSprite2D")
		player_sprite.play("attack")
		# todo fix animation playing timing everywhere
		var enemy_sprite = enemy.get_node("AnimatedSprite2D")
		enemy_sprite.play("get_hit")
		await player_sprite.animation_finished
		player_sprite.stop()
		enemy.get_hit(player.hit())
		player.get_hit(enemy.hit())
	else:
		print("hes already dead...")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
