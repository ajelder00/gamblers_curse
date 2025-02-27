class_name MapRoom
extends Area2D

signal selected(room:Room)
const ICON_SIZE := 2.5
const ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.BATTLE: [preload("res://map_stuff/map_tutorial_stuff/art/battle.png"), Vector2(ICON_SIZE+1,ICON_SIZE+1)],
	Room.Type.CASINO: [preload("res://map_stuff/map_tutorial_stuff/art/dice.png"), Vector2(ICON_SIZE+1.5,ICON_SIZE+1.5)],
	Room.Type.SHOP: [preload("res://map_stuff/map_tutorial_stuff/art/coins.png"), Vector2(ICON_SIZE,ICON_SIZE)],
	Room.Type.ELITE_BATTLE: [preload("res://map_stuff/map_tutorial_stuff/art/skull.png"), Vector2(ICON_SIZE + 2,ICON_SIZE + 2)],
	Room.Type.LOOT: [preload("res://map_stuff/map_tutorial_stuff/art/chest.png"), Vector2(ICON_SIZE,ICON_SIZE)],
	Room.Type.BOSS: [preload("res://map_stuff/map_tutorial_stuff/art/skull_boss.png"), Vector2(4,4)]
}
@onready var sprite_2d: Sprite2D = $visuals/icons
@onready var line_2d: Line2D = $visuals/line
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
	line_2d.rotation_degrees = randi_range(0,360)
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]

func show_selected() -> void:
	line_2d.modulate = Color.WHITE

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("click"):
		return
	room.selected = true
	animation_player.play("slam")

func _on_map_selected() -> void:
	selected.emit(room)
