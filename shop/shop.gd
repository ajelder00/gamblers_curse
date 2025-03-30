extends Node2D

@export var dice_templates: Dictionary = {
	"standard": preload("res://dice/dice.tscn"),
	"risky": preload("res://dice/risky/risky_dice.tscn"),
	"poison": preload("res://dice/poison/poison_dice.tscn"),
	"healing": preload("res://dice/healing/healing_dice.tscn"),
	"blinding": preload("res://dice/blinding/blinding_dice.tscn")
}

@onready var positions = [
	$StartPosition1, $StartPosition2, $StartPosition3,
	$StartPosition4, $StartPosition5, $StartPosition6
]

@onready var inventory_positiions = [
	$StartPosition7, $StartPosition8, $StartPosition9,
	$StartPosition10, $StartPosition11, $StartPosition12, 
	$StartPosition13, $StartPosition14, $StartPosition15, $StartPosition16 
]

@onready var button_container = $PurchaseButtonContainer
@onready var sell_button_container = $SellButtonContainer
@onready var message_label = $ShopDisplay
@onready var coin_label = $CoinDisplay
@onready var update_delay_timer = $UpdateDelayTimer

@export var button_icon: Texture2D = preload("res://art/button.png")

var player_inventory = Global.dice


var dice_prices = {
	"standard": 5,
	"risky": 10,
	"poison": 20,
	"healing": 15,
	"blinding": 12
}

var purchased_instances: Array = []

func _ready():
	coin_label.text = str(Global.coins)
	populate_sell_buttons()
	populate_shop()
	update_inventory_display()

# ---------------------- Styled Button ----------------------

func create_styled_button(text: String) -> Button:
	var button = Button.new()
	button.text = text

	var style = StyleBoxTexture.new()
	style.texture = button_icon
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("disabled", style)

	button.add_theme_constant_override("alignment", 1)
	button.custom_minimum_size = Vector2(200, 30)

	return button

# ---------------------- Shop ----------------------

func populate_shop():
	var dice_type_list = dice_templates.keys()

	for i in range(positions.size()):
		var dice_type = dice_type_list[randi() % dice_type_list.size()]
		var dice_scene = dice_templates[dice_type].instantiate()
		dice_scene.global_position = positions[i].global_position

		# Disable interaction visuals
		if "set_as_display_only" in dice_scene:
			dice_scene.set_as_display_only()
		else:
			if dice_scene.has_node("Button"):
				var b = dice_scene.get_node("Button")
				b.disabled = true
				b.hide()
			if dice_scene.has_node("AnimatedSprite2D"):
				var a = dice_scene.get_node("AnimatedSprite2D")
				a.stop()
				a.frame = 0
			if dice_scene.has_node("NameLabel"):
				dice_scene.get_node("NameLabel").visible = false

		add_child(dice_scene)

		var tween = create_tween()
		tween.tween_property(dice_scene, "position:y", dice_scene.position.y - 5, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(dice_scene, "position:y", dice_scene.position.y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		purchased_instances.append({ "type": dice_type, "scene": dice_scene })

		var button = create_styled_button("Buy %s (%d coins)" % [dice_type.capitalize(), dice_prices[dice_type]])
		button_container.add_child(button)

		var idx := i
		button.pressed.connect(func() -> void:
			handle_purchase(idx, button)
		)

# ---------------------- Purchase & Sell ----------------------

func handle_purchase(index: int, button: Button) -> void:
	var entry = purchased_instances[index]
	var dice_type = entry["type"]
	var shop_scene = entry["scene"]
	var price = dice_prices[dice_type]

	if player_inventory.size() >= 10:
		message_label.text = "Inventory full! (10 dice max)"
		return

	if Global.coins >= price:
		Global.coins -= price

		player_inventory.append(dice_templates[dice_type])

		message_label.text = "Purchased dice: %s" % dice_type
		button.disabled = true
		button.text = "Purchased"
		coin_label.text = str(Global.coins)

		await animate_dice_into_inventory(dice_type, shop_scene.global_position)
		await delay_inventory_update()  

		populate_sell_buttons()         
	else:
		message_label.text = "Not enough coins to buy: %s!" % dice_type

func handle_sell(index: int) -> void:
	if index < player_inventory.size():
		var dice_scene = player_inventory[index]
		var dice_type = get_dice_type(dice_scene)

		if dice_prices.has(dice_type):
			var refund = dice_prices[dice_type] / 2
			player_inventory.remove_at(index)
			Global.coins += refund
			message_label.text = "Sold %s for %d coins." % [dice_type, refund]
			populate_sell_buttons()
			coin_label.text = str(Global.coins)
			await delay_inventory_update()
		else:
			message_label.text = "Error: Unknown dice type."
	else:
		message_label.text = "Invalid sell index."

# ---------------------- Inventory Display ----------------------

func update_inventory_display() -> void:
	for pos in inventory_positiions:
		for child in pos.get_children():
			child.queue_free()

	for i in range(min(player_inventory.size(), inventory_positiions.size())):
		var dice_scene = player_inventory[i]
		var dice_instance = dice_scene.instantiate()

		if "set_as_display_only" in dice_instance:
			dice_instance.set_as_display_only()
		else:
			if dice_instance.has_node("Button"):
				dice_instance.get_node("Button").disabled = true
				dice_instance.get_node("Button").hide()
			if dice_instance.has_node("AnimatedSprite2D"):
				var anim = dice_instance.get_node("AnimatedSprite2D")
				anim.stop()
				anim.animation = Dice.ANIMS[dice_instance.type][0]
				anim.frame = 0
			if dice_instance.has_node("NameLabel"):
				dice_instance.get_node("NameLabel").visible = false

		dice_instance.scale = Vector2(0.9, 0.9)
		dice_instance.position = Vector2.ZERO
		inventory_positiions[i].add_child(dice_instance)

# ---------------------- Sell Buttons ----------------------

func populate_sell_buttons():
	clear_sell_buttons()

	for i in range(player_inventory.size()):
		var dice_scene = player_inventory[i]
		var dice_type = get_dice_type(dice_scene)

		if dice_prices.has(dice_type):
			var refund = dice_prices[dice_type] / 2
			var sell_button = create_styled_button("Sell %s (+%d coins)" % [dice_type.capitalize(), refund])
			sell_button_container.add_child(sell_button)

			var index := i
			sell_button.pressed.connect(func() -> void:
				handle_sell(index)
			)
		else:
			print("Warning: Unknown dice type in inventory: ", dice_scene)

func clear_sell_buttons():
	for child in sell_button_container.get_children():
		child.queue_free()

# ---------------------- Animate Dice ----------------------

func animate_dice_into_inventory(dice_type: String, start_position: Vector2) -> void:
	if player_inventory.size() > inventory_positiions.size():
		return

	var target_index = player_inventory.size() - 1
	var target_position = inventory_positiions[target_index].global_position

	var dice_instance = dice_templates[dice_type].instantiate()
	dice_instance.global_position = start_position
	dice_instance.scale = Vector2(0.6, 0.6)
	add_child(dice_instance)

	if "set_as_display_only" in dice_instance:
		dice_instance.set_as_display_only()
	else:
		if dice_instance.has_node("Button"):
			dice_instance.get_node("Button").disabled = true
			dice_instance.get_node("Button").hide()
		if dice_instance.has_node("AnimatedSprite2D"):
			var anim = dice_instance.get_node("AnimatedSprite2D")
			anim.stop()
			anim.animation = Dice.ANIMS[dice_instance.type][0]
			anim.frame = 0
		if dice_instance.has_node("NameLabel"):
			dice_instance.get_node("NameLabel").visible = false

	var tween = create_tween()
	tween.tween_property(dice_instance, "global_position", target_position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	dice_instance.queue_free()

# ---------------------- Delay ----------------------

func delay_inventory_update():
	update_delay_timer.start(0.3)
	await update_delay_timer.timeout
	update_inventory_display()

# ---------------------- Utility ----------------------

func get_dice_type(dice_scene: PackedScene) -> String:
	var instance = dice_scene.instantiate()
	if instance is Dice:
		# Attempt to assign the correct type from scene path
		var scene_path = dice_scene.resource_path.to_lower()
		
		if scene_path.find("risky") != -1:
			instance.type = Dice.Type.RISKY
		elif scene_path.find("poison") != -1:
			instance.type = Dice.Type.POISON
		elif scene_path.find("healing") != -1:
			instance.type = Dice.Type.HEALING
		elif scene_path.find("blinding") != -1:
			instance.type = Dice.Type.BLIND
		else:
			instance.type = Dice.Type.STANDARD  # fallback
		
		return Dice.Type.keys()[instance.type].to_lower()
	return "unknown"


# ---------------------- Return to Map ----------------------

func _on_return_to_map_button_pressed() -> void:
	print("pressed")
	return_to_map()

func return_to_map():
	print("Returning to map...")
	queue_free()
