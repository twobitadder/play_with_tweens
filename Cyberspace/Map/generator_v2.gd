extends Node2D

var room_template = preload("res://Cyberspace/Map/MapRoom.tscn")
var object_resource = preload("res://Cyberspace/Objects/Resources/object_data.gd")

var num_rooms : int
var corridors := {}
var after_first_pass := false
var traverse_cost : float setget ,get_traverse_cost
var is_valid_map := false

func _ready() -> void:
	randomize()
	while !is_valid_map:
		is_valid_map = true
		generate()

func _process(_delta: float) -> void:
	update()

func get_traverse_cost() -> float:
	return WorldState.server.traverse_cost

func generate() -> void:
	for child in $Rooms.get_children():
		child.free()
	
	for ice in WorldState.server.ice.keys():
		ice.destruct()
	
	WorldState.server.ice.clear()
	WorldState.server.rooms.clear()
	corridors.clear()
	after_first_pass = false
	WorldState.server.placed_heart = false
	WorldState.server.placed_mind = false
	place_rooms()
	connect_rooms()
	place_objects()
	show_neighbors(Vector2.ZERO)
	invert_room_data()
	update()

func place_rooms() -> void:
	var max_size = WorldState.server.max_size
	var min_size = WorldState.server.min_size
	num_rooms = randi() % (max_size - min_size) + min_size
	
	var entrance = room_template.instance()
	entrance.type = MapRoom.TYPE.ENTRANCE
	WorldState.server.rooms[Vector2.ZERO] = entrance
	$Rooms.add_child(entrance)
	entrance.position = $TileMap.map_to_world(Vector2.ZERO)
	spawn_neighbors(Vector2.ZERO)
	if WorldState.server.rooms.size() < num_rooms:
		after_first_pass = true
		spawn_neighbors(Vector2.ZERO)

func spawn_neighbors( grid_position) -> void:
	var min_size = WorldState.server.min_size
	var neighbors_to_spawn : int
	if WorldState.server.rooms.size() < min_size || after_first_pass:
		#anywhere from 1-3 neighbors
		neighbors_to_spawn = randi() % 3 + 1
	else:
		#anywhere from 0-3
		neighbors_to_spawn = randi() % 4
	
# warning-ignore:narrowing_conversion
	neighbors_to_spawn = min(neighbors_to_spawn, num_rooms - WorldState.server.rooms.size())
	
	if neighbors_to_spawn == 0:
		return
	
	var next_rooms := {}
	var directions := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	directions.shuffle()
	while neighbors_to_spawn > 0:
		if directions.size() == 0:
			break
		
		var next_dir = directions.pop_front() + grid_position
		if (WorldState.server.rooms.has(next_dir)):
			continue
		
		var blank_room = room_template.instance()
		blank_room.type = determine_room()
		WorldState.server.rooms[next_dir] = blank_room
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
			if !WorldState.server.has_heart || WorldState.server.placed_heart:
				continue
			else:
				WorldState.server.placed_heart = true
		elif num == MapRoom.TYPE.MIND:
			if !WorldState.server.has_mind || WorldState.server.placed_mind:
				continue
			else:
				WorldState.server.placed_mind = true
		num_valid = true
	
	return num

func connect_rooms() -> void:
	var temp_corridors := {}
	var unconnected_rooms = WorldState.server.rooms.duplicate()
	for room in WorldState.server.rooms.keys():
		var neighbors := [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN]
		#the cascading indent from hell!!!!
		#basically if the room exists in that direction, the corridor doesn't already exist, and it passes a rand check
		#then add it to the list of corridors. also remove the room from a list of rooms that do not have a corridor yet
		for neighbor in neighbors:
			if WorldState.server.rooms.has(room + neighbor):
				if !temp_corridors.has([room, room + neighbor] && !temp_corridors.has([room + neighbor, room])):
					if randf() < WorldState.server.interconnectedness:
						if unconnected_rooms.has(room):
							unconnected_rooms.erase(room)
						temp_corridors[[room, room + neighbor]] = [WorldState.server.rooms[room].position, WorldState.server.rooms[room + neighbor].position]
	
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
					WorldState.server.rooms[child].add_tree_parent(WorldState.server.rooms[next_room])
					process_stack.append(child)
		processed.append(next_room)
	
	processed.clear()
	
	var iterator := 0
	
	while unconnected_rooms.size() > processed.size() && iterator < 100:
		iterator += 1
		if iterator == 100:
			break
		
		for unconnected in unconnected_rooms.keys():
			var neighbors := [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN]
			neighbors.shuffle()
			for neighbor in neighbors:
				if WorldState.server.rooms.has(unconnected + neighbor) && \
				(WorldState.server.rooms[unconnected + neighbor].parents.size() > 0 || WorldState.server.rooms[unconnected + neighbor].type == MapRoom.TYPE.ENTRANCE):
					temp_corridors[[unconnected, unconnected + neighbor]] = [WorldState.server.rooms[unconnected].position, WorldState.server.rooms[unconnected + neighbor].position]
					WorldState.server.rooms[unconnected + neighbor].add_tree_parent(WorldState.server.rooms[unconnected])
					processed.append(unconnected)
	
	if iterator >= 100:
		for room in unconnected_rooms.keys():
			WorldState.server.rooms.erase(room)
		
	
	for corridor in temp_corridors.keys():
		corridors[corridor] = [false, temp_corridors[corridor]]

func place_objects() -> void:
	var placed_ice := 0
	var placed_data := 0
	var iterations := 0
	
	#if all rooms are data or no rooms are data
	var ok_data := false
	var ok_non_data := false
	for room in WorldState.server.rooms.keys():
		if WorldState.server.rooms[room].type == MapRoom.TYPE.DATA:
			ok_data = true
		elif WorldState.server.rooms[room].type != MapRoom.TYPE.DATA && WorldState.server.rooms[room].type != MapRoom.TYPE.ENTRANCE:
			ok_non_data = true
	
	if !ok_data || !ok_non_data:
		is_valid_map = false
		return
	
	while placed_ice < WorldState.server.num_ice || placed_data < WorldState.server.num_data:
		var placed := false
		var room_queue = WorldState.server.rooms.keys().duplicate()
		room_queue.shuffle()
		for room in room_queue:
			if WorldState.server.rooms[room].type == MapRoom.TYPE.ENTRANCE:
				continue
			match WorldState.server.rooms[room].type:
				MapRoom.TYPE.DATA:
					var new_object = object_resource.new()
					new_object.create(WorldState.server.server_strength, ObjectData.TYPE.DATA)
					WorldState.server.rooms[room].objects.append(new_object)
					new_object.grid_position = room
					placed_data += 1
					placed = true
				_:
					if placed_ice <= WorldState.server.num_ice:
						var new_object = object_resource.new()
						new_object.create(WorldState.server.server_strength)
						WorldState.server.rooms[room].objects.append(new_object)
						new_object.grid_position = room
						placed_ice += 1
						placed = true
		if !placed:
			iterations += 1
		if iterations >= WorldState.server.max_iterations:
			is_valid_map = false
			return

func get_loc(grid_pos) -> Vector2:
	return $TileMap.map_to_world(grid_pos)

func test_move(start_grid, dest_grid) -> bool:
	if !WorldState.server.rooms.has(dest_grid):
		return false
	
	var start_room = WorldState.server.rooms[start_grid]
	var dest_room = WorldState.server.rooms[dest_grid]
	
	if start_room.has_child(dest_room) || start_room.has_parent(dest_room):
		show_neighbors(dest_grid)
		return true
	
	return false

func show_neighbors(coord) -> void:
	for child in WorldState.server.rooms[coord].children:
		child.get_ref().show()
	
	for parent in WorldState.server.rooms[coord].parents:
		parent.get_ref().show()
	
	var neighbors = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
	
	for neighbor in neighbors:
		if corridors.has([coord, coord + neighbor]):
			corridors[[coord, coord + neighbor]][0] = true
		elif corridors.has([coord + neighbor, coord]):
			corridors[[coord + neighbor, coord]][0] = true

#data currently is: room contains ice
#provide a dictionary with inverted information - ice as the key, containing room coordinate as value
func invert_room_data() -> void:
	for room in WorldState.server.rooms.keys():
		for object in WorldState.server.rooms[room].objects:
			if object.type != ObjectData.TYPE.DATA:
				WorldState.server.ice[object] = room

func _draw() -> void:
	for corridor in corridors.keys():
		if corridors[corridor][0]:
			draw_line(corridors[corridor][1][0], corridors[corridor][1][1], Color.black, 5.0)
