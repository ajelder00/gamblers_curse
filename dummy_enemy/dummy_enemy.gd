extends Node2D
class_name DummyEnemy  

# --- Enemy Properties ---
var health: int = 50
var tier_multiplier: int 
enum Type{AXEMAN, GOBLIN, KNIGHT, LANCER, ORCRIDER, SKELETON, WIZARD, WOLF}
var damage : int
var self_statuses := []
var statuses_to_apply := []
var accuracy : float = 1.0
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

# Sound variables
@onready var attack_sound = AudioStreamPlayer.new()
@onready var attack_sound_path = load("res://dummy_enemy/dummy_enemy_sounds/17_orc_atk_sword_1.wav")
@onready var hit_sound = AudioStreamPlayer.new()
@onready var hit_sound_path = load("res://dummy_enemy/dummy_enemy_sounds/21_orc_damage_1.wav")

@export var type: Type = Type.GOBLIN
# --- Initialization ---
func _ready() -> void:
	initialize_enemy()
	setup_ui()
	
	# fixes animation
	sprite.animation = ANIMS[type][0]
	
	# Adding music as children and setting path
	add_child(attack_sound)
	attack_sound.stream = attack_sound_path
	add_child(hit_sound)
	hit_sound.stream = hit_sound_path


# --- Setup UI Elements ---
func setup_ui() -> void:
	sprite.flip_h = true
	dice_button.hide()

# --- Enemy Attack ---
func hit() -> Array:
	attack_sound.play()
	sprite.play(ANIMS[type][0])
	dice.roll_die(dice.faces)
	if accuracy >= randf_range(0, 1):
		return [damage, dice.status_effect]
	else: 
		return [0, 0]  # TODO: add into the battle text a thing ab how the enemy missed cause blind

# --- Enemy Takes Damage ---
func get_hit(damage_status: Array) -> void:
	for effect in damage_status[1]:
		self_statuses.append(effect)
	apply_status_self(self_statuses) # TODO: Update each effect for an animation/sprite
	
	health = max(0, health - damage_status[0])  # Prevent negative health


# --- Function to Initialize Enemy Values (To Be Overridden by Subclasses) ---
func initialize_enemy() -> void:
	pass


func _on_dice_rolled(value, status_effect):
	damage = value
	if status_effect:
		statuses_to_apply.append(status_effect)
	
func apply_status_self(effect_names) -> void:
	for effect in effect_names:
		match effect[0]:
			Global.Status.POISON:
				if effect[1] > 0: # The dice returns effect[type, duration], so effect[1] is duration
					health = max(0, health - Global.POISON_DAMAGE)
					print("Poisened for " + str(Global.POISON_DAMAGE) + " Damage")
					effect[1] -= 1
					sprite.modulate = Color(0, 1, 0)
				elif effect[1] <= 0:
					self_statuses.erase(effect)
					sprite.modulate = Color(1, 1, 1)

			Global.Status.BLINDNESS:
				if effect[1] > 0:
					accuracy = 0.5
					effect[1] -= 1
				elif effect[1] <= 0:
					accuracy = 1.0
