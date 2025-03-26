extends Node2D
class_name DummyEnemy  

# --- Enemy Properties ---
var health: int = 50
var tier_multiplier: int 
enum Type{AXEMAN, GOBLIN, KNIGHT, LANCER, ORCRIDER, SKELETON, WIZARD, WOLF}
var damage
var self_statuses := []
var statuses_to_apply := []
var accuracy : float = 1.0
var coins: int = randi_range(0,10)

signal damage_over
signal damage_to_player(damage_packet: Damage)

const ANIMS := {
	Type.AXEMAN: ["attack_axeman", "damage_axeman", "dead_axeman", "idle_axeman"],
	Type.GOBLIN: ["attack_goblin", "damage_goblin", "dead_goblin", "idle_goblin"],
	Type.KNIGHT: ["attack_knight", "damage_knight", "dead_knight", "idle_knight"],
	Type.LANCER: ["attack_lancer", "damage_lancer", "dead_lancer", "idle_lancer"],
	Type.ORCRIDER: ["attack_orcrider", "damage_orcrider", "dead_orcrider", "idle_orcrider"],
	Type.SKELETON: ["attack_skeleton", "damage_skeleton", "dead_skeleton", "idle_skeleton"],
	Type.WIZARD: ["attack_wizard", "damage_wizard", "dead_wizard", "idle_wizard"],
	Type.WOLF: ["attack_wolf", "damage_wolf", "dead_wolf", "idle_wolf"],
}

# --- References to Nodes ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dice: Node = $Dice
@onready var dice_button: Button = $Dice/Button
@onready var parent = get_parent()

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
	dice.rolled.connect(_on_die_rolled)
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

func _on_die_rolled(damage_packet: Damage):
	if accuracy >= randf_range(0, 1):
		damage = damage_packet
	else: 
		damage =  Damage.create(0, Global.Status.NOTHING, 0, dice.type)
	await dice.animation_player.animation_finished
	damage_to_player.emit(damage)
	attack_sound.play()
	sprite.play(ANIMS[type][0])

# --- Function to Initialize Enemy Values (To Be Overridden by Subclasses) ---
func initialize_enemy() -> void:
	pass


# --- Enemy Takes Damage ---
func get_hit(damage_packet_list: Array) -> void:
	for packet in damage_packet_list:
		if packet.status != Global.Status.NOTHING:
			if len(self_statuses) < 3:
				self_statuses.append([packet.status, packet.duration])
				print("Appended " + str(packet.status) + " to enemy")
			elif len(self_statuses) >= 3:
				print("Erased " + str(self_statuses[0]) + " from enemy statuses")
				self_statuses.pop_front()
				self_statuses.append([packet.status, packet.duration])
				print("And appended " + str(packet.status))
		if not packet.damage_number == 0:
			sprite.play(ANIMS[type][1])
			health = max(0, health - packet.damage_number)
			parent.update_health_display() # applies damage and prevents negative health
			await sprite.animation_finished
			sprite.animation = ANIMS[type][3]
	await get_tree().create_timer(1).timeout
	apply_status_self(self_statuses) # TODO: Update each effect for an animation/sprite



func apply_status_self(effect_names) -> void:
	for effect in effect_names:
		match effect[0]:
			Global.Status.POISON:
				if effect[1] > 0: # The dice returns effect[type, duration], so effect[1] is duration
					health = max(0, health - Global.POISON_DAMAGE)
					parent.update_health_display()
					print("Poisened for " + str(Global.POISON_DAMAGE) + " Damage")
					effect[1] -= 1
					sprite.modulate = Color(0, 1, 0)
					sprite.animation = ANIMS[type][1]
					sprite.play()
					await sprite.animation_finished
					sprite.animation = ANIMS[type][3]
				elif effect[1] <= 0:
					self_statuses.erase(effect)
					sprite.modulate = Color(1, 1, 1)

			Global.Status.BLINDNESS:
				if effect[1] > 0:
					accuracy = 0.5
					effect[1] -= 1
				elif effect[1] <= 0:
					accuracy = 1.0
	if effect_names != []:
		await get_tree().create_timer(1).timeout
		print("awaiting status effects")
	damage_over.emit()
	print("damage_over emitted")
