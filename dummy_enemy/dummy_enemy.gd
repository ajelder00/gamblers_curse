extends Node2D
class_name DummyEnemy  

# --- Enemy Properties ---
var health: int = 200
var tier_multiplier: int 
enum Type{AXEMAN, GOBLIN, KNIGHT, LANCER, ORCRIDER, SKELETON, WIZARD, WOLF}
var damage

const ANIMS := {
	Type.AXEMAN: ["attack_axeman", "damage_axeman", "dead_axeman"],
	Type.GOBLIN: ["attack_goblin", "damage_goblin", "dead_goblin"],
	Type.KNIGHT: ["attack_knight", "damage_knight", "dead_knight"],
	Type.LANCER: ["attack_lancer", "damage_lancer", "dead_lancer"],
	Type.ORCRIDER: ["attack_orcrider", "damage_orcrider", "dead_orcrider"],
	Type.SKELETON: ["attack_skeleton", "damage_skeleton", "dead_skeleton"],
	Type.WIZARD: ["attack_wizard", "damage_wizard", "dead_wizard"],
	Type.WOLF: ["attack_wolf", "damage_wolf", "dead_wolf"],
}

# --- References to Nodes ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dice: Node = $Dice
@onready var dice_button: Button = $Dice/Button

@export var type: Type = Type.GOBLIN
# --- Initialization ---
func _ready() -> void:
	initialize_enemy()
	setup_ui()


# --- Setup UI Elements ---
func setup_ui() -> void:
	sprite.flip_h = true
	dice_button.hide()

# --- Enemy Attack ---
func hit() -> int:
	sprite.play(ANIMS[type][0])
	dice.roll_die(dice.faces)
	return damage

# --- Enemy Takes Damage ---
func get_hit(enemy_damage: int) -> void:
	sprite.play(ANIMS[type][0])
	await sprite.animation_finished
	health = max(0, health - enemy_damage)  # Prevent negative health


# --- Function to Initialize Enemy Values (To Be Overridden by Subclasses) ---
func initialize_enemy() -> void:
	pass


func _on_dice_rolled(value):
	damage = value
