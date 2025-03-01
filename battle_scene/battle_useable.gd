extends Node
@export var player_template: PackedScene
@export var enemy_template: PackedScene

var player
var player_sprite
var enemy
var enemy_sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = player_template.instantiate()
	enemy = enemy_template.instantiate()
	add_child(player)
	add_child(enemy)
	player.attack_signal.connect(_on_player_attack)
	player_sprite = player.get_node("AnimatedSprite2D")
	player_sprite.animation = "attack"
	enemy_sprite = enemy.get_node("AnimatedSprite2D")
	



func _on_player_attack() -> void:
	if Global.player_health > 0 and enemy.health > 0:
		# ----- Player Turn -----  
		player_sprite.play("attack")
		await player_sprite.animation_finished
		
		# ----- Update Enemy Health 
		await enemy.get_hit(player.hit())
		
		# ----- Enemy Turn 
		if enemy.health <= 0: 
			enemy_sprite.play("dead")
			print("You have vanquished your enemy.")
			return
			
		player.get_hit(enemy.hit()) 
		await enemy_sprite.animation_finished
			
		print("Full Turn")	
		print("This is Player's health: ", Global.player_health)	
		print("This is enemy's health: ", enemy.health)
		
		# code for getting new hand from Dice Roller, this makes it so it shows the dice faces and roll total
		player.get_node("Dice Roller").new_hand()
			
		if Global.player_health <= 0: 
			player_sprite.play("dead")
			print("Your player has exited this world")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
