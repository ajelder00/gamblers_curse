extends Node2D

@onready var parent = get_parent()
@onready var roller = $"Dice Roller"
@onready var sprite = $"AnimatedSprite2D"

# Music stuff
@onready var attack_sound = AudioStreamPlayer.new()
@onready var attack_sound_path = load("res://dummy_player/dummy_player_sounds/07_human_atk_sword_2.wav")
@onready var hit_sound = AudioStreamPlayer.new()
@onready var hit_sound_path = load("res://dummy_player/dummy_player_sounds/11_human_damage_1.wav")
@onready var indicator1 = $StatusIndicator1
@onready var indicator2 = $StatusIndicator2
@onready var indicator3 = $StatusIndicator3
@onready var indicator_label1 = $StatusIndicator1/Duration1
@onready var indicator_label2 = $StatusIndicator2/Duration2
@onready var indicator_label3 = $StatusIndicator3/Duration3
var current_effects := []

signal attack_signal
# Called when the node enters the scene tree for the first time.
signal damage_over
signal effects_over

func _ready() -> void:
	var indicator_list = [indicator1, indicator2, indicator3]
	var label_list = [indicator_label1, indicator_label2, indicator_label3]
	for indicator in indicator_list:
		indicator.modulate.a = 0.0
	for label in label_list:
		label.text = ""
	Global.connect("player_healed", _on_healed)
	roller.turn_over.connect(_on_dice_roller_turn_over)
	sprite.play("idle")
	# Adding music as children and setting path
	add_child(attack_sound)
	attack_sound.stream = attack_sound_path
	add_child(hit_sound)
	hit_sound.stream = hit_sound_path

func hit() -> Array :
	return roller.current_results

func get_hit(packet: Damage):
	update_indicators()
	for effect in current_effects: #Deletes any effects that ran out
		if effect.duration == 0:
			current_effects.erase(effect)
			update_indicators()
	sprite.play("get_hit")
	if packet.status != Global.Status.NOTHING and packet.accuracy >= randf_range(0,1):
		if len(current_effects) < 3: # Adds the packet to the effects list if the effects list is less than 3
			current_effects.append(packet)
			update_indicators()
		elif len(current_effects) >= 3: # Handles cases where the statuses list is full alr
			replace_status(packet)
			update_indicators()
	hit_sound.play()
	if not packet.damage_number == 0:
		Global.player_health = max(0, Global.player_health - packet.damage_number)
		floating_text(("-" + str(packet.damage_number)), Color.DARK_RED)
		parent.update_health_display()
		await sprite.animation_finished
		sprite.play("idle")
	else:
		floating_text("Miss", Color.WHITE_SMOKE)
		await get_tree().create_timer(1).timeout
	damage_over.emit()

func _on_dice_roller_turn_over() -> void:
	attack_signal.emit()



# Plays the attack sound, as a function since battle is going to call it
# Prevents the need to create another path to a child of player
func play_attack_sound():
	attack_sound.play()

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

func _on_healed(heal_amount):
	parent.update_health_display()
	if Global.can_heal:
		floating_text("+" + str(heal_amount), Color.GREEN_YELLOW)
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "modulate", Color(0.6, 1.0, 0.6), 0.5)  # Fade to green in 0.5s
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.5)
	else:
		floating_text("Cursed! -" + str(heal_amount), Color.DARK_RED)
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "modulate", Color(0.6, 0.2, 0.8), 0.5)  # Fade to purple in 0.5s
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.5)

func apply_status_self(effect_names) -> void:
	update_indicators()
	for effect in effect_names:
		match effect.status:
			Global.Status.CURSE:
				if effect.duration > 0:
					Global.can_heal = false
					effect.duration -= 1
					update_indicators()
					floating_text("Cursed", Color.DARK_ORCHID)
					var tween = get_tree().create_tween()
					tween.tween_property(sprite, "modulate", Color(0.4, 0.1, 0.5, 1.0), 0.5)
					await tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.5).finished
			Global.Status.BLEEDING:
				if effect.duration > 0:
					Global.player_health = max(0, Global.player_health - effect.damage_number)
					floating_text(("-" + str(effect.damage_number)), Color.RED)
					parent.update_health_display()
					effect.duration -= 1
					update_indicators()
					sprite.modulate = Color(1, 0, 0)
					sprite.play("get_hit")
					await sprite.animation_finished
					sprite.play("idle")
					sprite.modulate = Color(1, 1, 1)
	for effect in effect_names: #Deletes any effects that ran out
		if effect.duration == 0:
			effect_names.erase(effect)
			update_indicators()
		update_indicators()
	if effect_names != []:
		await get_tree().create_timer(1).timeout
	await get_tree().create_timer(1).timeout
	effects_over.emit()


func replace_status(new_packet: Damage) -> void:
	var current_lowest_value = 100
	for packet in current_effects:
		if packet.duration < current_lowest_value:
			current_lowest_value = packet.duration
	for packet in current_effects:
		if (packet.status == new_packet.status) and (packet.duration == current_lowest_value) and (packet.duration <= new_packet.duration):
			packet.duration = new_packet.duration
			packet.damage_number = new_packet.damage_number
			break
		elif (packet.duration == current_lowest_value) and (packet.status != new_packet.status):
			current_effects.erase(packet)
			current_effects.append(new_packet)

func update_indicators() -> void:
	if indicator_label1.text == "0":
		indicator1.modulate.a = 0
	if indicator_label2.text == "0":
		indicator1.modulate.a = 0
	if indicator_label3.text == "0":
		indicator1.modulate.a = 0

	if len(current_effects) >= 1:
		indicator1.texture = load(Global.STATUS_PICS[current_effects[0].status])
		indicator_label1.text = str(current_effects[0].duration)
		indicator1.modulate.a = 1.0
	else:
		indicator1.modulate.a = 0
	if len(current_effects) >= 2:
		indicator2.texture = load(Global.STATUS_PICS[current_effects[1].status])
		indicator_label2.text = str(current_effects[1].duration)
		indicator2.modulate.a = 1.0
	else:
		indicator2.modulate.a = 0
	if len(current_effects) == 3:
		indicator3.texture = load(Global.STATUS_PICS[current_effects[2].status])
		indicator_label3.text = str(current_effects[2].duration)
		indicator3.modulate.a = 1.0
	else:
		indicator3.modulate.a = 0
