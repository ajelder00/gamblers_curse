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

const NAMES := {
	Type.AXEMAN: "HEADSMAN",
	Type.GOBLIN: "DUNGEON GOBLIN",
	Type.KNIGHT: "POSSESSED KNIGHT",
	Type.LANCER: "CORRUPT JOUSTER",
	Type.ORCRIDER: "ORC RIDER",
	Type.SKELETON: "RISEN SKELETON",
	Type.WIZARD: "WICKED SORCERER",
	Type.WOLF: "DIREWOLF",
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
@export var immunities : Array = []
@export var turns : int = 1
# --- Initialization ---
func _ready() -> void:
	initialize_enemy()
	setup_ui()
	dice.rolled.connect(_on_die_rolled)
	# fixes animation
	sprite.play(ANIMS[type][3])
	
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
	await sprite.animation_finished
	sprite.play(ANIMS[type][3])

# --- Function to Initialize Enemy Values (To Be Overridden by Subclasses) ---
func initialize_enemy() -> void:
	pass


# --- Enemy Takes Damage ---
func get_hit(damage_packet_list: Array) -> void:
	for effect in self_statuses: #Deletes any effects that ran out
		if effect.duration == 0:
			self_statuses.erase(effect)

	for packet in damage_packet_list: # Checks through each sent packet from the player
		if packet.type == Dice.Type.HEALING:
			Global.heal(packet.damage_number)
			await get_tree().create_timer(1).timeout
			continue
		if packet.type in immunities:
			floating_text("Immune!", Color.WHITE_SMOKE)
			await get_tree().create_timer(1).timeout
			continue

		if packet.status != Global.Status.NOTHING:
			if len(self_statuses) < 3: # Adds the packet to the effects list if the effects list is less than 3
				self_statuses.append(packet)

			elif len(self_statuses) >= 3: # Handles cases where the statuses list is full alr
				replace_status(packet)

		if not packet.damage_number == 0: # Only runs if theres damage to implement
			sprite.play(ANIMS[type][1])
			health = max(0, health - packet.damage_number)
			floating_text(("-" + str(packet.damage_number)), Color.DARK_RED)
			parent.update_health_display() # applies damage and prevents negative health
			await sprite.animation_finished
			sprite.play(ANIMS[type][3])
	await get_tree().create_timer(1).timeout
	apply_status_self(self_statuses) # TODO: Update each effect for an animation/sprite



func apply_status_self(effect_names) -> void:
	if len(effect_names) == 3:
		print(str(effect_names[0].duration) + str(effect_names[1].duration) + str(effect_names[2].duration))
	for effect in effect_names:
		match effect.status:
			Global.Status.POISON:
				if effect.duration > 0: # The dice returns effect[type, duration], so effect[1] is duration
					health = max(0, health - Global.POISON_DAMAGE)
					parent.update_health_display()
					effect.duration -= 1
					sprite.modulate = Color(0, 1, 0)
					sprite.animation = ANIMS[type][1]
					sprite.play()
					await sprite.animation_finished
					sprite.play(ANIMS[type][3])
					sprite.modulate = Color(1, 1, 1)

			Global.Status.BLINDNESS:
				if effect[1] > 0:
					accuracy = 0.5
					effect[1] -= 1
				elif effect[1] <= 0:
					accuracy = 1.0
	if effect_names != []:
		await get_tree().create_timer(1).timeout
	damage_over.emit()

func replace_status(new_packet: Damage) -> void:
	var current_lowest_value = 100
	for packet in self_statuses:
		if packet.duration < current_lowest_value:
			current_lowest_value = packet.duration
	for packet in self_statuses:
		if (packet.status == new_packet.status) and (packet.duration == current_lowest_value):
			packet.duration = new_packet.duration
			break
		elif packet.duration == current_lowest_value:
			self_statuses.erase(packet)
			self_statuses.append(new_packet)

func floating_text(text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 30)
	add_child(label)
	
	label.position = Vector2(
		randf_range(label.position.x +50, label.position.x - 50),
		randf_range(label.position.y +30, label.position.y)
	)
	
	var tween = get_tree().create_tween()
	var target_position = label.position + Vector2(randi_range(-10, 10), -50)
	tween.tween_property(label, "position", target_position, 0.75).set_trans(Tween.TRANS_SINE)
	
	# Fade out
	tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 0.75)
	await tween.finished
	label.queue_free()
