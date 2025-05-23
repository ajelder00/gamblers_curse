class_name MapRoom
extends Area2D

signal selected(room:Room)

const ICON_SIZE := 5.5
const ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.BATTLE: [preload("res://map_stuff/map_tutorial_stuff/art/map_icons/battle.png"), Vector2(ICON_SIZE,ICON_SIZE)],
	Room.Type.CASINO: [preload("res://map_stuff/map_tutorial_stuff/art/map_icons/dice.png"), Vector2(ICON_SIZE,ICON_SIZE)],
	Room.Type.SHOP: [preload("res://map_stuff/map_tutorial_stuff/art/map_icons/coins.png"), Vector2(ICON_SIZE,ICON_SIZE)],
	Room.Type.ELITE_BATTLE: [preload("res://map_stuff/map_tutorial_stuff/art/map_icons/skull.png"), Vector2(ICON_SIZE,ICON_SIZE)],
	Room.Type.LOOT: [preload("res://map_stuff/map_tutorial_stuff/art/map_icons/chest.png"), Vector2(ICON_SIZE,ICON_SIZE)],
	Room.Type.BOSS: [preload("res://map_stuff/map_tutorial_stuff/art/map_icons/skull_boss.png"), Vector2(ICON_SIZE, ICON_SIZE)],
	Room.Type.TUTORIAL: [preload("res://map_stuff/map_tutorial_stuff/art/map_icons/battle.png"), Vector2(ICON_SIZE,ICON_SIZE)],
}
@onready var sprite_2d: Sprite2D = $Visuals/Icons
@onready var x_out: Sprite2D = $Visuals/X
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var available := false : set = set_available
var room: Room : set = set_room

func set_available(new_value: bool) -> void:
	available = new_value
	if available:
		animation_player.play("pulsate")
	elif not room.selected:
		animation_player.play("RESET")

func set_room(new_data: Room) -> void:
	room = new_data
	position = room.position
	x_out.rotation_degrees += randi_range(0,10)
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]

func show_selected() -> void:
	x_out.modulate = Color.WHITE

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("click"):
		return
	room.selected = true
	animation_player.play("slam")

func _on_map_selected() -> void:
	selected.emit(room)
