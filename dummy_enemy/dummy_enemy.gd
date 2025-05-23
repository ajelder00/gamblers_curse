extends Node2D
class_name DummyEnemy  

# --- Enemy Properties ---
enum Type{AXEMAN, GOBLIN, KNIGHT, LANCER, ORCRIDER, SKELETON, WIZARD, WOLF, KING, SLIME}
var damage
var self_statuses := []
var accuracy = base_accuracy
var fire_pop := {}

var was_frozen_this_turn := false
var was_hypnotized_this_turn := false

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
	Type.KING: ["attack_king", "damage_king", "dead_king", "idle_king"],
	Type.SLIME: ["attack_slime", "damage_slime", "dead_slime", "idle_slime"]
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
	Type.KING: "EVIL KING"
}

# --- References to Nodes ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var dice: Node = null
var dice_button: Button = null
@onready var parent = get_parent()
@onready var indicator1 = $StatusIndicator1
@onready var indicator2 = $StatusIndicator2
@onready var indicator3 = $StatusIndicator3
@onready var indicator_label1 = $StatusIndicator1/Duration1
@onready var indicator_label2 = $StatusIndicator2/Duration2
@onready var indicator_label3 = $StatusIndicator3/Duration3

# Sound variables
@onready var attack_sound = AudioStreamPlayer.new()
@onready var attack_sound_path = load("res://dummy_enemy/dummy_enemy_sounds/17_orc_atk_sword_1.wav")
@onready var hit_sound = AudioStreamPlayer.new()
@onready var hit_sound_path = load("res://dummy_enemy/dummy_enemy_sounds/21_orc_damage_1.wav")

#things that change
var type: Type = Type.GOBLIN
var immunities : Array = []
var turns : int = 1
var health : int = 50
var tier : int = 1
var coins: int = 0
var base_accuracy : float = 1.0
var dice_bucket : Array = [null]

# --- Initialization ---
func _ready() -> void:
	coins = int(randi_range(5,10)*randf_range(tier,tier + 1))
	set_dice()
	initialize_enemy()
	setup_ui()
	# fixes animation
	sprite.play(ANIMS[type][3])
	# Adding music as children and setting path
	add_child(attack_sound)
	attack_sound.stream = attack_sound_path
	add_child(hit_sound)
	hit_sound.stream = hit_sound_path

func set_dice() -> void:
	if dice_bucket[0] == null:
		return
	for die in dice_bucket:
		die.rolled.connect(_on_die_rolled)
	dice = dice_bucket.pick_random()
	dice.modulate.a = 1
	for die in dice_bucket:
		if die != dice:
			die.modulate.a = 0
	dice_button = dice.button

# --- Setup UI Elements ---
func setup_ui() -> void:
	sprite.flip_h = true
	var indicator_list = [indicator1, indicator2, indicator3]
	var label_list = [indicator_label1, indicator_label2, indicator_label3]
	for indicator in indicator_list:
		indicator.modulate.a = 0.0
	for label in label_list:
		label.text = ""

func _on_die_rolled(damage_packet: Damage):
	var is_frozen = false

	for effect in self_statuses:
		if effect.status == Global.Status.HYPNOSIS and effect.duration > 0:
			was_hypnotized_this_turn = true
			floating_text("Enemy is asleep!", Color.MEDIUM_PURPLE)
			damage = Damage.create(0, Global.Status.NOTHING, 0, dice.type)
			damage_to_player.emit(damage)
			return

	if accuracy >= randf_range(0, 1):
		for effect in self_statuses:
			if effect.status == Global.Status.FROZEN and effect.duration > 0:
				is_frozen = true
				was_frozen_this_turn = true
				if randf_range(0, 1) < 0.5:
					floating_text("Frozen — Can't Attack!", Color.SKY_BLUE)
					damage = Damage.create(0, Global.Status.NOTHING, 0, dice.type)
				else:
					damage = Damage.create(
						int(floor(damage_packet.damage_number / 2)),
						damage_packet.status,
						damage_packet.duration,
						damage_packet.type,
						damage_packet.accuracy
					)
					floating_text("Frozen — Weakened!", Color.LIGHT_BLUE)
				break
		if not is_frozen:
			damage = damage_packet
	else:
		damage = Damage.create(0, Global.Status.NOTHING, 0, dice.type)

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
	for packet in damage_packet_list: # Checks through each sent packet from the player
		if packet.type == Dice.Type.CHANCE:
			if packet.damage_number == 999:
				update_indicators()
				sprite.play(ANIMS[type][1])
				hit_sound.play()
				floating_text("LUCKY STRIKE!", Color.YELLOW)
				health = max(0, health - packet.damage_number)
				floating_text(("-" + str(packet.damage_number)), Color.DARK_RED)
				parent.update_health_display() # applies damage and prevents negative health
				await sprite.animation_finished
				sprite.play(ANIMS[type][3])
				continue
			elif packet.damage_number == -999:
				Global.can_heal = false
				#player dies
				Global.self_destruct()
				print("Chance backfire (meant for player) ignored by enemy.")
				continue
		if packet.type == Dice.Type.HEALING:
			Global.heal(packet.damage_number)
			await get_tree().create_timer(1).timeout
			continue
		if packet.type in immunities:
			floating_text("Immune!", Color.WHITE_SMOKE)
			await get_tree().create_timer(1).timeout
			continue
		if packet.status != Global.Status.NOTHING and packet.accuracy >= randf_range(0,1):
			if len(self_statuses) < 3: # Adds the packet to the effects list if the effects list is less than 3
				self_statuses.append(packet)
			elif len(self_statuses) >= 3: # Handles cases where the statuses list is full alr
				replace_status(packet)
			update_indicators()
		if type == Type.AXEMAN and packet.damage_number < 3:
			floating_text("Too Armored...", Color.WHITE_SMOKE)
			await get_tree().create_timer(1).timeout
		elif not packet.damage_number == 0: # Only runs if theres damage to implement
			update_indicators()
			sprite.play(ANIMS[type][1])
			hit_sound.play()
			health = max(0, health - packet.damage_number)
			floating_text(("-" + str(packet.damage_number)), Color.DARK_RED)
			parent.update_health_display() # applies damage and prevents negative health
			await sprite.animation_finished
			sprite.play(ANIMS[type][3])
		else:
			floating_text("Miss", Color.WHITE_SMOKE)
			await get_tree().create_timer(1).timeout
	await get_tree().create_timer(1).timeout
	apply_status_self(self_statuses) # TODO: Update each effect for an animation/sprite



func apply_status_self(effect_names) -> void:
	update_indicators()
	var fire_erase := []
	var affected_accuracy = base_accuracy
	for effect in effect_names:
		print("duration: " + str(effect.duration))
		print(effect_names)
		match effect.status:
			Global.Status.FROZEN:
				update_indicators()
				if was_frozen_this_turn:
					effect.duration -= 1
					update_indicators()
			Global.Status.HYPNOSIS:
				update_indicators()
				if was_hypnotized_this_turn:
					effect.duration -= 1
					update_indicators()
			Global.Status.POISON:
				if effect.duration > 0: # The dice returns effect[type, duration], so effect[1] is duration
					health = max(0, health - effect.damage_number)
					floating_text(("-" + str(effect.damage_number)), Color.GREEN)
					parent.update_health_display()
					effect.duration -= 1
					update_indicators()
					sprite.modulate = Color(0, 1, 0)
					sprite.play(ANIMS[type][1])
					await sprite.animation_finished
					sprite.play(ANIMS[type][3])
					sprite.modulate = Color(1, 1, 1)
			Global.Status.BLINDNESS:
				if effect.duration > 0:
					effect.duration -= 1
					update_indicators()
					if affected_accuracy < 0.3:
						floating_text("ACCURACY CAN'T GO LOWER", Color.DARK_ORCHID)
					else:
						affected_accuracy -= (base_accuracy * (float(effect.damage_number)/10))
						floating_text(("-" + str(effect.damage_number*10)) + "% ACCURACY", Color.DARK_ORCHID)
						var tween = get_tree().create_tween()
						tween.tween_property(sprite, "modulate", Color(0.4, 0.1, 0.5, 1.0), 0.5)
						await tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.5).finished
			Global.Status.DROWNING:
				if effect.duration > 0:
					if effect.duration <= 3:
						effect.duration -= 1
						update_indicators()
						health = max(0, health - (effect.damage_number + 4))
						floating_text(("-" + str(effect.damage_number + 4)), Color.DODGER_BLUE)
						parent.update_health_display()
						sprite.modulate = Color(0.2, 0.2, 1)
						sprite.play(ANIMS[type][1])
						await sprite.animation_finished
						sprite.play(ANIMS[type][3])
						sprite.modulate = Color(1, 1, 1)
					elif effect.duration > 3:
						floating_text("LOSING AIR", Color.AQUAMARINE)
						effect.duration -= 1
						update_indicators()
						await get_tree().create_timer(.5).timeout
					print(affected_accuracy)
			Global.Status.FIRE:
				if effect.duration > 0:
					if effect not in fire_pop:
						effect.duration -= 1
						update_indicators()
						if dice.type != Dice.Type.CHAR:
							dice_bucket.erase(dice)
							var char = Global.char.instantiate() #new charred dice instantiation
							add_child(char)
							char.button.hide()
							dice_bucket.append(char)
							fire_pop[effect] = [dice, char]
							char.position = dice.position
							dice.modulate.a = 0
							dice = char
						elif dice.type == Dice.Type.CHAR:
							for die in dice_bucket:
								if die.type != Dice.Type.CHAR:
									dice_bucket.erase(die)
									var char = Global.char.instantiate() #new charred dice instantiation
									add_child(char)
									char.button.hide()
									dice_bucket.append(char)
									fire_pop[effect] = [die, char]
									char.position = die.position
									char.modulate.a = 0
									break
					else:
						effect.duration -= 1
						update_indicators()
					floating_text("DICE BURNED", Color.SANDY_BROWN)
					var tween = get_tree().create_tween()
					tween.tween_property(sprite, "modulate", Color(1.0, 0.5, 0.0, 1.0), 0.5)
					await tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.5).finished
				elif effect.duration == 0:
					fire_erase.append(effect)
	for effect in effect_names:
		if effect.duration == 0 and effect.status != Global.Status.FIRE:
			self_statuses.erase(effect)
	if fire_erase != []:
		floating_text("DICE RESTORED", Color.ORANGE)
		for effect in fire_erase:
			revert_fire(effect)
	update_indicators()
	if effect_names != []:
		await get_tree().create_timer(0.5).timeout
	accuracy = max(affected_accuracy, 0.3)
	print("accuracy: " + str(accuracy))
	
	was_frozen_this_turn = false
	was_hypnotized_this_turn = false
	
	update_indicators()
	print(dice_bucket)
	damage_over.emit()

func revert_fire(effect):
	self_statuses.erase(effect)
	update_indicators()
	if effect in fire_pop:
		dice_bucket.erase(fire_pop[effect][1])
		print("Clearing Fire from" + str(effect)) 
		dice_bucket.append(fire_pop[effect][0])
		fire_pop[effect][1].queue_free()
		fire_pop.erase(effect)
		set_dice()


func replace_status(new_packet: Damage) -> void:
	var current_lowest_value = 100
	for packet in self_statuses:
		if packet.duration < current_lowest_value:
			current_lowest_value = packet.duration
	for packet in self_statuses:
		if (packet.status == new_packet.status) and (packet.duration == current_lowest_value):
			packet.duration = new_packet.duration
			return
		elif packet.duration == current_lowest_value:
			if packet.status == Global.Status.FIRE:
				revert_fire(packet)
				self_statuses.append(new_packet)
				return
			self_statuses.erase(packet)
			self_statuses.append(new_packet)
			return
	if self_statuses[0] == Global.Status.FIRE:
		revert_fire(self_statuses[0])
		self_statuses.append(new_packet)
		return
	self_statuses.erase(self_statuses[0])
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

func update_indicators() -> void:

	if len(self_statuses) >= 1:
		indicator1.texture = load(Global.STATUS_PICS[self_statuses[0].status])
		indicator_label1.text = str(self_statuses[0].duration)
		indicator1.modulate.a = 1.0
		if indicator_label1.text == "0":
			indicator1.modulate.a = 0
	else:
		indicator1.modulate.a = 0
	if len(self_statuses) >= 2:
		indicator2.texture = load(Global.STATUS_PICS[self_statuses[1].status])
		indicator_label2.text = str(self_statuses[1].duration)
		indicator2.modulate.a = 1.0
		if indicator_label2.text == "0":
			indicator2.modulate.a = 0
	else:
		indicator2.modulate.a = 0
	if len(self_statuses) == 3:
		indicator3.texture = load(Global.STATUS_PICS[self_statuses[2].status])
		indicator_label3.text = str(self_statuses[2].duration)
		indicator3.modulate.a = 1.0
		if indicator_label3.text == "0":
			indicator3.modulate.a = 0
	else:
		indicator3.modulate.a = 0
