extends Node2D

@onready var chest_sprite = $Chest
@onready var open_text = $OpenText
@onready var unlock = $Unlock
@onready var unlock_label = $Unlock/UText
@onready var map_rect = $Map

var chest_clicked = false
var bobbing_speed = 2.0
var bobbing_height = 5.0
var original_label_position

var unlock_message = "DUNGEON CHEST UNLOCKED!\n\nYOU FOUND:\n\nPOISON DICE\n\n100 GOLD!\n\n..."
var second_message = "RETURNING TO MAP..."

func _ready():
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
	unlock.visible = true
	await get_tree().create_timer(0.5).timeout
	var tween = create_tween()
	tween.tween_property(unlock, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	await typewriter_effect(unlock_message)
	await get_tree().create_timer(1.0).timeout
	unlock_label.text = ""
	await typewriter_effect(second_message)
	await get_tree().create_timer(0.5).timeout
	fade_in_map()

func fade_in_map():
	map_rect.visible = true
	var map_tween = create_tween()
	map_tween.tween_property(map_rect, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_LINEAR)

func typewriter_effect(message: String):
	for i in message.length():
		unlock_label.text = message.substr(0, i + 1)
		await get_tree().create_timer(0.1).timeout
