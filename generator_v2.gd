extends Node2D

var room_template = preload("res://MapRoom.tscn")

export var min_size := 5
export var max_size := 15
export var max_iterations := 100
export var interconnectedness := .65

var num_rooms : int
var rooms := {}
var corridors := {}
var after_first_pass := false
var has_heart := true
var has_mind := true

class RoomSorter:
	static func sort_rooms(a, b) -> bool:
		if a.steps < b.steps:
			return true
		elif a.steps == b.steps && a.type <= b.type:
			return true
		return false

func _ready() -> void:
	randomize()
	generate()

func _process(delta: float) -> void:
	update()

func generate() -> void:
	for child in $Rooms.get_children():
		child.queue_free()
	
	rooms.clear()
	corridors.clear()
	after_first_pass = false
	has_heart = true
	has_mind = true
	place_rooms()
	connect_rooms()
	show_neighbors(Vector2.ZERO)
	update()

func place_rooms() -> void:
	num_rooms = randi() % (max_size - min_size) + min_size
	
	var entrance = room_template.instance()
	entrance.type = MapRoom.TYPE.ENTRANCE
	rooms[Vector2.ZERO] = entrance
	$Rooms.add_child(entrance)
	entrance.position = $TileMap.map_to_world(Vector2.ZERO)
	print(rooms.size())
	spawn_neighbors(Vector2.ZERO)
	print(rooms.size())
	if rooms.size() < num_rooms:
		after_first_pass = true
		spawn_neighbors(Vector2.ZERO)

func spawn_neighbors( grid_position) -> void:
	var neighbors_to_spawn : int
	if rooms.size() < min_size || after_first_pass:
		#anywhere from 1-3 neighbors
		neighbors_to_spawn = randi() % 3 + 1
	else:
		#anywhere from 0-3
		neighbors_to_spawn = randi() % 4
	
# warning-ignore:narrowing_conversion
	neighbors_to_spawn = min(neighbors_to_spawn, num_rooms - rooms.size())
	
	if neighbors_to_spawn == 0:
		return
	
	var next_rooms := {}
	var directions := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	directions.shuffle()
	while neighbors_to_spawn > 0:
		if directions.size() == 0:
			break
		
		var next_dir = directions.pop_front() + grid_position
		if (rooms.has(next_dir)):
			continue
		
		var blank_room = room_template.instance()
		blank_room.type = determine_room()
		rooms[next_dir] = blank_room
		$Rooms.add_child(blank_room)
		blank_room.hide()
		blank_room.position = $TileMap.map_to_world(next_dir)
		next_rooms[next_dir] = blank_room
	
	for next_room in next_rooms.keys():
		spawn_neighbors(next_room)

func determine_room() -> int:
	var num_valid = false
	var num = 0
	while !num_valid:
		#1 to 5
		num = randi() % 5 + 1
		if num == MapRoom.TYPE.HEART:
			if !has_heart:
				continue
			else:
				has_heart = false
		elif num == MapRoom.TYPE.MIND:
			if !has_mind:
				continue
			else:
				has_mind = false
		num_valid = true
	
	return num

func connect_rooms() -> void:
	var temp_corridors := {}
	var unconnected_rooms = rooms.duplicate()
	for room in rooms.keys():
		var neighbors := [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN]
		#the cascading indent from hell!!!!
		#basically if the room exists in that direction, the corridor doesn't already exist, and it passes a rand check
		#then add it to the list of corridors. also remove the room from a list of rooms that do not have a corridor yet
		for neighbor in neighbors:
			if rooms.has(room + neighbor):
				if !temp_corridors.has([room, room + neighbor] && !temp_corridors.has([room + neighbor, room])):
					if randf() < interconnectedness:
						if unconnected_rooms.has(room):
							unconnected_rooms.erase(room)
						temp_corridors[[room, room + neighbor]] = [rooms[room].position, rooms[room + neighbor].position]
	
	determine_steps(temp_corridors, unconnected_rooms)

func determine_steps(temp_corridors, unconnected_rooms) -> void:
	var process_stack := [Vector2.ZERO]
	var processed := []
	while process_stack.size() > 0:
		var next_room = process_stack.pop_front()
		for corridor in temp_corridors.keys():
			if corridor.has(next_room):
				var remaining_room = corridor.duplicate()
				remaining_room.erase(next_room)
				var child = remaining_room[0]
				if !processed.has(child):
					rooms[child].add_tree_parent(rooms[next_room])
					process_stack.append(child)
		processed.append(next_room)
	
	processed.clear()
	
	while unconnected_rooms.size() > processed.size():
		for unconnected in unconnected_rooms.keys():
			var neighbors := [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN]
			neighbors.shuffle()
			for neighbor in neighbors:
				if rooms.has(unconnected + neighbor) && \
				(rooms[unconnected + neighbor].parents.size() > 0 || rooms[unconnected + neighbor].type == MapRoom.TYPE.ENTRANCE):
					temp_corridors[[unconnected, unconnected + neighbor]] = [rooms[unconnected].position, rooms[unconnected + neighbor].position]
					rooms[unconnected + neighbor].add_tree_parent(rooms[unconnected])
					processed.append(unconnected)
		
	
	for corridor in temp_corridors.keys():
		corridors[corridor] = [false, temp_corridors[corridor]]

func get_loc(grid_pos) -> Vector2:
	return $TileMap.map_to_world(grid_pos)

func test_move(start_grid, dest_grid) -> bool:
	if !rooms.has(dest_grid):
		return false
	
	var start_room = rooms[start_grid]
	var dest_room = rooms[dest_grid]
	
	if start_room.children.has(dest_room) || start_room.parents.has(dest_room):
		show_neighbors(dest_grid)
		return true
	
	return false

func show_neighbors(coord) -> void:	
	for child in rooms[coord].children:
		child.show()
	
	for parent in rooms[coord].parents:
		parent.show()
	
	var neighbors = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
	
	for neighbor in neighbors:
		if corridors.has([coord, coord + neighbor]):
			corridors[[coord, coord + neighbor]][0] = true
		elif corridors.has([coord + neighbor, coord]):
			corridors[[coord + neighbor, coord]][0] = true

func _draw() -> void:
	for corridor in corridors.keys():
		if corridors[corridor][0]:
			draw_line(corridors[corridor][1][0], corridors[corridor][1][1], Color.black, 5.0)
