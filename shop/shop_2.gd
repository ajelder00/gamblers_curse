extends Node2D

@onready var coins = $PlayerCoins/Label
@onready var roller = $"PlayerInventory/Dice Roller"
@onready var player = $Player
@onready var sell_label = $PlayerCoins/Background2
@onready var text_bubbles = [$PlayerCoins/Label, $PlayerCoins/Label2, $PlayerCoins/Coin, $PlayerCoins/Background, $PlayerCoins/Background2]
@onready var to_buy = [$DiceToBuy/ShopDice, $DiceToBuy/ShopDice2, $DiceToBuy/ShopDice3, $DiceToBuy/ShopDice4, $DiceToBuy/ShopDice5, $DiceToBuy/ShopDice6, $DiceToBuy/ShopDice7, $DiceToBuy/ShopDice8, $DiceToBuy/ShopDice9, $DiceToBuy/ShopDice10]
@onready var return_controller_texture = $ReturnController/Texture
@onready var return_controller_text = $ReturnController/Return
@onready var coin_sound = $SoundEffect
var text_bubbles_pos
var inventory = []
var first_time = true

func _ready() -> void:
	text_bubbles_pos = [$PlayerCoins/Label.position.y, $PlayerCoins/Label2.position.y, $PlayerCoins/Coin.position.y, $PlayerCoins/Background.position.y, $PlayerCoins/Background2.position.y]
	update_coins()
	await _wait_for_dice_to_load()
	_connect_dice_signals() 

func _wait_for_dice_to_load():
	while len(Global.dice) != len(roller.current_dice):
		await get_tree().process_frame  # Wait for the next frame

func _connect_dice_signals():
	for dice in roller.current_dice:
		if not dice.rolled.is_connected(_on_die_rolled):
			dice.rolled.connect(_on_die_rolled.bind(dice))
			if not len(roller.current_dice) <= 3:
				dice.button.show()
			else: dice.button.hide()

func floating_text(text: String, color: Color, pos: Vector2) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)
	
	label.position = pos + Vector2(
		randf_range(label.position.x +20, label.position.x - 20),
		randf_range(label.position.y -30, label.position.y)
	)
	
	var tween = get_tree().create_tween()
	var target_position = label.position + Vector2(randi_range(-10, 10), -50)
	tween.tween_property(label, "position", target_position, 0.75).set_trans(Tween.TRANS_SINE)
	
	# Fade out
	tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 0.75)
	await tween.finished
	label.queue_free()

func _on_die_rolled(damage_packet: Damage, dice: Dice):
	for die in roller.current_dice:
		die.button.hide()
	await dice.animation_player.animation_finished
	var tween_transparency = get_tree().create_tween()
	tween_transparency.tween_property(dice, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_SINE)
	await tween_transparency.finished
	await get_tree().create_timer(.1).timeout
	floating_text("+" + str(damage_packet.damage_number) + " GOLD", Color.GOLDENROD, dice.global_position)
	roller.current_dice.erase(dice)
	var global_to_erase = Global.shop_dict[dice.type]
	for item in Global.dice:
		if item == global_to_erase:
			Global.dice.erase(item)
			break
	Global.coins += damage_packet.damage_number
	if len(Global.dice) < 10:
		for item in to_buy:
			if is_instance_valid(item):
				item.dice.button.show()
	update_coins()
	dice.queue_free()
	roller.reset_positions()

#func _process(delta: float) -> void:
	#for i in range(len(text_bubbles)):
		#text_bubbles[i].position.y = text_bubbles_pos[i] + sin(Time.get_ticks_msec() / 1000.0 * 3) * 3

func update_coins() -> void:
	coins.text = (str(Global.coins) + " Coins")
	if not first_time:
		coin_sound.play()
	first_time = false

func _on_return_to_map_button_pressed() -> void:
	print("pressed")
	queue_free()


func _on_return_to_map_button_mouse_entered():
	return_controller_texture.scale *= 1.1
	return_controller_text.scale *= 1.1


func _on_return_to_map_button_mouse_exited():
	return_controller_texture.scale /= 1.1
	return_controller_text.scale /= 1.1
