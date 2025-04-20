class_name MapGenerator
extends Node

const X_DIST := 150
const Y_DIST := 200
const PLACEMENT_RANDOMNESS := 7
const MAP_WIDTH := 7
const PATHS := 4

var FLOORS := 8
var FIGHT_WEIGHT := 12
var GAMBLE_WEIGHT := 4
var ELITE_WEIGHT := 6
var SHOP_WEIGHT := 4
var LOOT_WEIGHT := 4
var random_room_weights := {
	Room.Type.BATTLE: 0.0,
	Room.Type.ELITE_BATTLE: 0.0,
	Room.Type.CASINO: 0.0,
	Room.Type.SHOP: 0.0,
	Room.Type.LOOT: 0.0
}
var random_room_total_weight := 0
var map_data: Array

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func generate_map() -> Array:
	map_data = _generate_initial_grid()
	var starting_points = _get_random_starting_points()
	
	for start_column in starting_points:
		var current_column = start_column
		for floor_index in range(FLOORS - 1):
			current_column = _setup_connection(floor_index, current_column)
	
	_setup_boss()
	_setup_random_room_weights()
	_setup_room_types()
	
	_setup_start()
	
	return map_data

func _generate_initial_grid() -> Array:
	var result := []
	
	for i in range(FLOORS):
		var row := []
		for j in range(MAP_WIDTH):
			var current_room = Room.new()
			var offset = Vector2(rng.randf(), rng.randf()) * PLACEMENT_RANDOMNESS
			
			current_room.position = Vector2(X_DIST * j, Y_DIST * i) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms = []
			
			if i == FLOORS - 1:
				current_room.position.y = Y_DIST * (i + 1)
			
			row.append(current_room)
		result.append(row)
	return result

func _get_random_starting_points() -> Array:
	var points := []
	while points.size() < PATHS:
		var p = rng.randi_range(0, MAP_WIDTH - 1)
		if not points.has(p):
			points.append(p)
	return points

func _setup_connection(floor_idx: int, column_idx: int) -> int:
	var current_room = map_data[floor_idx][column_idx] as Room
	var next_room: Room = null
	while next_room == null or _would_cross(floor_idx, column_idx, next_room):
		var random_j = clamp(rng.randi_range(column_idx - 1, column_idx + 1), 0, MAP_WIDTH - 1)
		next_room = map_data[floor_idx + 1][random_j] as Room
	current_room.next_rooms.append(next_room)
	return next_room.column

func _would_cross(floor_idx: int, column_idx: int, room: Room) -> bool:
	var left_neighbor: Room = null
	var right_neighbor: Room = null
	
	if column_idx > 0:
		left_neighbor = map_data[floor_idx][column_idx - 1]
	if column_idx < MAP_WIDTH - 1:
		right_neighbor = map_data[floor_idx][column_idx + 1]
		
	if right_neighbor and room.column > column_idx:
		for nr in right_neighbor.next_rooms:
			if nr.column < room.column:
				return true
	
	if left_neighbor and room.column < column_idx:
		for nr in left_neighbor.next_rooms:
			if nr.column > room.column:
				return true
	return false

func _setup_boss() -> void:
	var middle = int(MAP_WIDTH / 2)
	# Original boss position becomes a shop
	var shop_room = map_data[FLOORS - 1][middle] as Room
	shop_room.type = Room.Type.SHOP
	
	# Rewire connections from previous floor to shop
	for j in range(MAP_WIDTH):
		var current_room = map_data[FLOORS - 2][j] as Room
		if current_room.next_rooms.size() > 0:
			current_room.next_rooms.clear()
			current_room.next_rooms.append(shop_room)
	
	# Create a dedicated boss room one floor below
	var boss_room = Room.new()
	boss_room.row = FLOORS
	boss_room.column = middle
	boss_room.position = Vector2(X_DIST * middle, Y_DIST * FLOORS)
	boss_room.next_rooms = []
	boss_room.type = Room.Type.BOSS
	
	# Connect shop to boss
	shop_room.next_rooms.clear()
	shop_room.next_rooms.append(boss_room)
	
	# Append new boss floor
	map_data.append([boss_room])
	FLOORS += 1

func _setup_random_room_weights() -> void:
	random_room_weights[Room.Type.BATTLE] = FIGHT_WEIGHT
	random_room_weights[Room.Type.ELITE_BATTLE] = FIGHT_WEIGHT + ELITE_WEIGHT
	random_room_weights[Room.Type.CASINO] = FIGHT_WEIGHT + ELITE_WEIGHT + GAMBLE_WEIGHT
	random_room_weights[Room.Type.SHOP] = FIGHT_WEIGHT + ELITE_WEIGHT + GAMBLE_WEIGHT + SHOP_WEIGHT
	random_room_weights[Room.Type.LOOT] = FIGHT_WEIGHT + ELITE_WEIGHT + GAMBLE_WEIGHT + SHOP_WEIGHT + LOOT_WEIGHT

	random_room_total_weight = random_room_weights[Room.Type.LOOT]

func _setup_room_types() -> void:
	# Ensure first non-start floor always has loot rooms on paths
	for room in map_data[1]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.LOOT

	# Assign types to all other rooms
	for floor in map_data:
		for room in floor:
			for nr in room.next_rooms:
				if nr.type == Room.Type.NOT_ASSIGNED:
					_set_room_randomly(nr)

func _set_room_randomly(room: Room) -> void:
	if room.row == 1:
		room.type = Room.Type.BATTLE
		return
	if room.row == 2:
		room.type = Room.Type.SHOP
		return

	var consecutive_shop = true
	var consecutive_loot = true
	var consecutive_gambling = true
	var type_candidate: Room.Type

	while consecutive_shop or consecutive_loot or consecutive_gambling:
		type_candidate = _get_candidate_by_weight()
		consecutive_shop = _room_has_parent_of_type(room, Room.Type.SHOP) and type_candidate == Room.Type.SHOP
		consecutive_loot = _room_has_parent_of_type(room, Room.Type.LOOT) and type_candidate == Room.Type.LOOT
		consecutive_gambling = _room_has_parent_of_type(room, Room.Type.CASINO) and type_candidate == Room.Type.CASINO

	room.type = type_candidate

func _room_has_parent_of_type(room: Room, t: Room.Type) -> bool:
	if room.row == 0:
		return false
	for parent in map_data[room.row - 1]:
		if parent.next_rooms.has(room) and parent.type == t:
			return true
	return false

func _setup_start() -> void:
	var start_room = Room.new()
	var middle = int(MAP_WIDTH / 2)
	start_room.column = middle
	start_room.row = -1
	start_room.position = Vector2(X_DIST * middle, -250)
	start_room.type = Room.Type.TUTORIAL
	start_room.next_rooms = []

	for room in map_data[0]:
		if room.next_rooms.size() > 0:
			start_room.next_rooms.append(room)

	map_data.insert(0, [start_room])
	FLOORS += 1

func _get_candidate_by_weight() -> Room.Type:
	var roll = rng.randf_range(0.0, random_room_total_weight)
	for t in random_room_weights.keys():
		if random_room_weights[t] > roll:
			return t
	return Room.Type.BATTLE
