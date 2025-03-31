extends Node2D

@onready var label = $Label
@onready var marker = $Marker2D
var dice
var dice_to_add
var dont_gray = true

func _ready() -> void:
	if randf() < max(((float(Global.difficulty)/10) - 0.4), 0.2):
		queue_free()
		pass
	dice_to_add = Global.dummy_dice.pick_random()
	dice = dice_to_add.instantiate()
	self.add_child(dice)
	dice.position = marker.position
	dice.rolled.connect(_on_die_rolled.bind(dice))
	label.position = marker.position
	label.position.y += 45
	label.position.x -= 36
	label.text = str(dice.cost) + " COINS"

func _on_die_rolled(damage_packet: Damage, dice: Dice):
	Global.dice.append(dice_to_add)
	if len(Global.dice) >= 10:
		for node in get_parent().get_parent().to_buy:
			if is_instance_valid(node):
				node.dice.button.hide()
	dice.animation_player.stop()
	var tween_transparency = get_tree().create_tween()
	tween_transparency.tween_property(dice, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_SINE)
	await tween_transparency.finished
	await get_tree().create_timer(.1).timeout
	get_parent().get_parent().floating_text("-" + str(dice.cost) + " GOLD", Color.GOLDENROD, dice.global_position)
	Global.coins -= dice.cost

	get_parent().get_parent().roller.add_new_dice(dice_to_add)
	get_parent().get_parent().update_coins()
	queue_free()

func _process(delta):
	if dice != null:
		dice.position.y = marker.position.y + sin(Time.get_ticks_msec() / 1000.0 * 2.5) * 3
