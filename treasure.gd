extends Node2D

@onready var chest_sprite = $Chest
@onready var open_text = $OpenText
@onready var unlock = $Unlock
@onready var unlock_label = $UText
@onready var map_rect = $Map
@onready var camera = $Camera2D
@onready var coin_pic = $Coin
@onready var marker = $Marker2D
@onready var die = null

var chest_clicked = false
var bobbing_speed = 2.0
var bobbing_height = 5.0
var original_label_position
var dice_loot = Global.dummy_dice.duplicate()
var coins = randi_range(10, 40)
var loot

var unlock_message = "DUNGEON CHEST UNLOCKED!"
var second_message = "RETURNING TO MAP..."

func _ready():
	if randf() > 0.4:
		loot = coin_pic
	else:
		die = dice_loot.pick_random()
		loot = die.instantiate()
		self.add_child(loot)
		loot.modulate.a = 0.0
		loot.button.hide()
		loot.position = marker.position
		loot.scale = loot.scale*1.5
	original_label_position = open_text.position
	unlock.modulate.a = 0.0
	unlock.visible = false
	unlock_label.text = ""
	map_rect.modulate.a = 0.0
	map_rect.visible = false
	chest_sprite.animation_finished.connect(_on_chest_animation_finished)

func _process(delta: float) -> void:
	open_text.position.y = original_label_position.y + sin(Time.get_ticks_msec() / 1000.0 * bobbing_speed) * bobbing_height

func _on_chest_animation_finished():
	if chest_sprite.animation == "open":
		chest_sprite.play("idle")

func _on_color_rect_mouse_entered() -> void:
	if not chest_clicked:
		chest_sprite.scale *= 1.1

func _on_color_rect_mouse_exited() -> void:
	if not chest_clicked:
		chest_sprite.scale /= 1.1

func _on_color_rect_gui_input(event: InputEvent) -> void:
	if chest_clicked:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		chest_sprite.play("open")
		chest_clicked = true
		open_text.text = ""
		fade_in_unlock()

func fade_in_unlock():
	var tween1 = get_tree().create_tween()  
	tween1.tween_property(camera, "zoom", Vector2(1.1, 1.1), 0.5)  # Smooth zoom in over 0.5s
	unlock.visible = true
	await get_tree().create_timer(0.5).timeout
	await typewriter_effect(unlock_message)
	var tween2 = get_tree().create_tween()  
	await tween2.tween_property(loot, "modulate:a", 1.0, 0.5)
	await get_tree().create_timer(1.5).timeout
	unlock_label.text = ""
	if die:
		loot.roll_die(loot.faces)
		Global.dice.append(die)
		await typewriter_effect("YOU FOUND A " + str(loot.TYPE_NAMES[loot.type][0]).to_upper() + " DICE")
	else:
		Global.coins += coins
		await typewriter_effect("YOU FOUND " + str(coins) + " COINS")
	unlock.visible = true
	await get_tree().create_timer(1.0).timeout
	unlock_label.text = ""
	await get_tree().create_timer(0.5).timeout
	fade_in_map()

func fade_in_map():
	map_rect.visible = true
	var map_tween = create_tween()
	map_tween.tween_property(map_rect, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_LINEAR)
	await get_tree().create_timer(1.8).timeout 
	queue_free() 

func typewriter_effect(message: String):
	for i in message.length():
		unlock_label.text = message.substr(0, i + 1)
		await get_tree().create_timer(0.08).timeout
