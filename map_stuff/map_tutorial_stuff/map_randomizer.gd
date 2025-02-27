class_name MapGenerator
extends Node

const X_DIST := 150
const Y_DIST := 200
const PLACEMENT_RANDOMNESS := 7
const MAP_WIDTH := 7
const PATHS := 4

var FLOORS := 6
var FIGHT_WEIGHT := 8
var GAMBLE_WEIGHT := 2.5
var ELITE_WEIGHT := 4.5
var SHOP_WEIGHT := 2.5
var LOOT_WEIGHT := 2.5
var random_room_weights = {
	Room.Type.BATTLE: 0.0,
	Room.Type.ELITE_BATTLE: 0.0,
	Room.Type.CASINO: 0.0,
	Room.Type.SHOP: 0.0,
	Room.Type.LOOT: 0.0
}
var random_room_total_weight := 0
var map_data : Array[Array]

func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()
	
	for j in starting_points:
		var current_j := j
		for i in FLOORS - 1:
			current_j = _setup_connection(i, current_j)
	
	_setup_boss()
	_setup_random_room_weights()
	_setup_room_types()
	
	_setup_start()
	
	return map_data

func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	
	for i in FLOORS:
		var adjacent_rooms: Array[Room] = []
		
		for j in MAP_WIDTH:
			var current_room := Room.new()
			var offset := Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			
			current_room.position = Vector2(X_DIST * j, Y_DIST * i) + offset
			current_room.row = i + 1
			current_room.column = j
			current_room.next_rooms = []
			
			if i == FLOORS - 1:
				current_room.position.y = (i+1) * Y_DIST 
			
			adjacent_rooms.append(current_room)
		result.append(adjacent_rooms)
	return result

func _get_random_starting_points() -> Array[int]:
	var y_coordinates : Array[int]
	var unique_points := 0
	
	while unique_points < 3:
		unique_points = 0
		y_coordinates = []
		
		for i in PATHS:
			var starting_point := randi_range(0,MAP_WIDTH-1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			y_coordinates.append(starting_point)
	return y_coordinates

func _setup_connection(i: int, j: int) -> int:
	var next_room: Room
	var current_room := map_data[i][j] as Room
	
	while not next_room or _would_cross(i, j, next_room):
		var random_j := clampi(randi_range(j-1, j+1), 0, MAP_WIDTH - 1)
		next_room = map_data[i+1][random_j]
	current_room.next_rooms.append(next_room)
	return next_room.column

func _would_cross(i: int, j: int, room: Room) -> bool:
	var left_neighbor: Room
	var right_neighbor: Room
	
	if j > 0:
		left_neighbor = map_data[i][j-1]
	if j < MAP_WIDTH - 1:
		right_neighbor = map_data[i][j+1]
		
	if right_neighbor and room.column > j:
		for next_room: Room in right_neighbor.next_rooms:
			if next_room.column < room.column:
				return true
	
	if left_neighbor and room.column < j:
		for next_room: Room in left_neighbor.next_rooms:
			if next_room.column > room.column:
				return true
	return false 

func _setup_boss() -> void:
	var middle := floori(MAP_WIDTH*0.5)
	var boss_room := map_data[FLOORS-1][middle] as Room
	
	for j in MAP_WIDTH:
		var current_room := map_data[FLOORS-2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
	boss_room.type = Room.Type.BOSS

func _setup_random_room_weights() -> void:
	random_room_weights[Room.Type.BATTLE] = FIGHT_WEIGHT
	random_room_weights[Room.Type.ELITE_BATTLE] = FIGHT_WEIGHT + ELITE_WEIGHT
	random_room_weights[Room.Type.CASINO] = FIGHT_WEIGHT + ELITE_WEIGHT + GAMBLE_WEIGHT
	random_room_weights[Room.Type.SHOP] = FIGHT_WEIGHT + ELITE_WEIGHT + GAMBLE_WEIGHT + SHOP_WEIGHT
	random_room_weights[Room.Type.LOOT] = FIGHT_WEIGHT + ELITE_WEIGHT + GAMBLE_WEIGHT + SHOP_WEIGHT + LOOT_WEIGHT

	random_room_total_weight = random_room_weights[Room.Type.LOOT]

func _setup_room_types() -> void:
# Makes the first room always a battle - repeat this with different map index to set floor room types
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.BATTLE

# Sets the rest of the rooms
	for current_floor in map_data:
		for room: Room in current_floor:
			for next_room in room.next_rooms:
				if next_room.type == Room.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)

func _set_room_randomly(room: Room) -> void:
	#If you want to make rules about what rooms can be at what level, go to the tutorial at the 1:00:00 mark
	var consecutive_shop := true
	var consecutive_loot := true
	var consecutive_gambling := true
	
	var type_candidate: Room.Type
	while consecutive_loot or consecutive_shop or consecutive_gambling:
		type_candidate = _get_candidate_by_weight()
		
		var is_shop := type_candidate == Room.Type.SHOP
		var is_loot := type_candidate == Room.Type.LOOT
		var is_gambling := type_candidate == Room.Type.CASINO
		
		consecutive_gambling =  _room_has_parent_of_type(room, Room.Type.CASINO) and is_gambling
		consecutive_shop =  _room_has_parent_of_type(room, Room.Type.SHOP) and is_shop
		consecutive_loot = _room_has_parent_of_type(room, Room.Type.LOOT) and is_loot
	room.type = type_candidate

func _room_has_parent_of_type(room: Room, type: Room.Type) -> bool:
	var parents: Array[Room] = []
	
	if room.column > 0 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column - 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	if room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	if room.column < MAP_WIDTH - 1 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column + 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	for parent: Room in parents:
		if parent.type == type:
			return true
	return false

func _setup_start() -> void:
	var start_room = Room.new()
	var middle := floori(MAP_WIDTH*0.5)
	start_room.column = middle
	start_room.row = 0
	start_room.position = Vector2(X_DIST * middle, -250)
	start_room.type = Room.Type.BATTLE
	for room in map_data[0]:
		if room.next_rooms:
			start_room.next_rooms.append(room)
	map_data.insert(0,[start_room])
	FLOORS += 1
	

func _get_candidate_by_weight() -> Room.Type:
	var roll := randf_range(0.0, random_room_total_weight)
	
	for type: Room.Type in random_room_weights:
		if random_room_weights[type] > roll:
			return type
	return Room.Type.BATTLE
