extends Node2D

const SCROLL_SPEED := 40
const MAP_ROOM = preload("res://map_stuff/map_tutorial_stuff/map_node.tscn")
const MAP_LINE = preload("res://map_stuff/map_tutorial_stuff/map_connector.tscn")
const BATTLE = preload("res://battle_scene/battle.tscn")
const LOOT = preload("res://loot/loot.tscn")
const SHOP = preload("res://shop/shop2.tscn")
const CASINO = preload("res://casino/dice_blackjack.tscn")
const ELITE = preload("res://rooms/elite/elite.tscn")
const TUTORIAL = preload("res://battle_scene/tutorial/tutorial_battle.tscn")
const BOSS = preload("res://rooms/boss/boss_battle.tscn")

signal map_exited

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals: Node2D = $Visuals
@onready var camera_2d: Camera2D = $Scroller
@onready var parent = get_parent()
@onready var background = $MapBackground/Background
@onready var map_audio: AudioStreamPlayer2D = $MapAudio
@onready var fade = $Fade  # Reference to the fade node

var map_data: Array[Array]
var floors_climbed: int
var last_room: Room
var camera_edge_y: float

func _ready() -> void:
	generate_new_map()
	camera_edge_y = MapGenerator.Y_DIST * (len(map_data) - 1)
	unlock_floor(-1)
	# Start playing map audio when the scene is ready
	map_audio.play()
	# Fade out the $Fade node on scene ready
	fade.modulate.a = 1.0  # Ensure it starts fully opaque
	create_tween().tween_property(fade, "modulate:a", 0.0, 1.0)

func get_lower_clamp(num_floors: int) -> float:
	var base_offset := 1000.0
	var additional_offset_per_floor := 1500.0 / 7.0  # increase per floor above 7
	var lower_offset := base_offset + additional_offset_per_floor * (num_floors - 7)
	return -camera_edge_y + lower_offset

func _input(event: InputEvent) -> void:
	var previous_cam_pos = camera_2d.position.y
	var previous_background_pos = background.position.y
	
	if event.is_action_pressed("scroll_up"):
		camera_2d.position.y -= SCROLL_SPEED
		background.position.y += (SCROLL_SPEED - 10)
	elif event.is_action_pressed("scroll_down"):
		camera_2d.position.y += SCROLL_SPEED
		background.position.y -= (SCROLL_SPEED - 10)
	
	var num_floors := len(map_data)
	var lower_clamp := get_lower_clamp(num_floors)
	var upper_clamp := num_floors * MapGenerator.Y_DIST - 150
	camera_2d.position.y = clamp(camera_2d.position.y, lower_clamp, upper_clamp)
	
	if camera_2d.position.y - previous_cam_pos == 0:
		background.position.y = previous_background_pos

func generate_new_map() -> void:
	floors_climbed = 0
	map_data = map_generator.generate_map()
	create_map()

func create_map() -> void:
	for current_floor in map_data:
		for room: Room in current_floor:
			if room.next_rooms.size() > 0:
				_spawn_room(room)
	# Spawn boss room
	var middle := floori(MapGenerator.MAP_WIDTH * 0.5)
	_spawn_room(map_data[len(map_data) - 1][middle])
	
	var map_width_pixels := MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = get_viewport_rect().size.y / 2

func unlock_floor(which_floor: int = floors_climbed) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true

func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		if last_room.next_rooms.has(map_room.room):
			map_room.available = true

func show_map() -> void:
	fade.modulate.a = 1.0  # Ensure it starts fully opaque
	create_tween().tween_property(fade, "modulate:a", 0.0, 1.0)
	show()
	camera_2d.enabled = true
	unlock_next_rooms()
	# Play map audio when showing the map
	map_audio.play()

func hide_map() -> void:
	fade.modulate.a = 0.0  # Ensure it starts fully opaque
	create_tween().tween_property(fade, "modulate:a", 1.0, 0.0)
	hide()
	camera_2d.enabled = false
	# Stop map audio when hiding the map
	map_audio.stop()
	
func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.selected.connect(_on_map_selected)
	_connect_lines(room)
	
	if room.selected and room.row < floors_climbed:
		new_map_room.show_selected()

func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return
		
	for next: Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)

func _on_map_selected(room: Room) -> void:
	# Stop the map audio when a room is selected (clicked)
	map_audio.stop()
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false
	last_room = room
	floors_climbed += 1
	Global.difficulty += 1
	map_exited.emit(room)  # I dont know what this signal does, but it scares me to delete it
	
	var scene_to_load # Determine which scene to load based on the room type
	match room.type:
		Room.Type.BATTLE:
			scene_to_load = BATTLE
		Room.Type.LOOT:
			scene_to_load = LOOT
		Room.Type.SHOP:
			scene_to_load = SHOP
		Room.Type.CASINO:
			scene_to_load = CASINO
		Room.Type.TUTORIAL:
			if (Global.attempts > 1):
				scene_to_load = BATTLE
			else:
				scene_to_load = TUTORIAL
		Room.Type.ELITE_BATTLE:
			scene_to_load = ELITE
		Room.Type.BOSS:
			scene_to_load = BOSS
	
	parent.add_child(scene_to_load.instantiate())
	hide_map()
