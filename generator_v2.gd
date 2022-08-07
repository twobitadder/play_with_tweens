extends Node2D

var room_template = preload("res://MapRoom.tscn")

export var min_size := 5
export var max_size := 15
export var max_iterations := 100

var num_rooms : int
var rooms := {}
var corridors := []
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

func generate() -> void:
	rooms.clear()
	corridors.clear()
	after_first_pass = false
	has_heart = true
	has_mind = true
	place_rooms()
	connect_rooms()
	determine_steps()
	organize_tree()
	update()

func place_rooms() -> void:
	num_rooms = randi() % (max_size - min_size) + min_size
	
	var entrance = room_template.instance()
	entrance.type = MapRoom.TYPE.ENTRANCE
	rooms[Vector2.ZERO] = entrance
	$Rooms.add_child(entrance)
	entrance.position = $TileMap.map_to_world(Vector2.ZERO)
	print(rooms.size())
	spawn_neighbors(entrance, Vector2.ZERO)
	print(rooms.size())
	if rooms.size() < num_rooms:
		after_first_pass = true
		spawn_neighbors(entrance, Vector2.ZERO)
	
	$Label.text = "target: %d" % num_rooms
	$Label2.text = "rooms: %d" % rooms.size()

func spawn_neighbors(room, grid_position) -> void:
	var neighbors_to_spawn : int
	if rooms.size() < min_size || after_first_pass:
		#anywhere from 1-3 neighbors
		neighbors_to_spawn = randi() % 3 + 1
	else:
		#anywhere from 0-3
		neighbors_to_spawn = randi() % 4
	
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
		blank_room.position = $TileMap.map_to_world(next_dir)
		next_rooms[next_dir] = blank_room
	
	for next_room in next_rooms.keys():
		spawn_neighbors(next_rooms[next_room], next_room)

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
	for room in rooms.keys():
		var neighbors := [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN]
		for neighbor in neighbors:
			if rooms.has(room + neighbor):
				if !temp_corridors.has([room, room + neighbor] && !temp_corridors.has([room + neighbor, room])):
					temp_corridors[[room, room + neighbor]] = [rooms[room].position, rooms[room + neighbor].position]
	
	for corridor in temp_corridors.values():
		corridors.append(corridor)

func determine_steps() -> void:
	pass 

func organize_tree() -> void:
	pass 

func _draw() -> void:
	for corridor in corridors:
		draw_line(corridor[0], corridor[1], Color.black, 5.0)

func _on_Button_pressed() -> void:
	for child in $Rooms.get_children():
		child.queue_free()

	generate()
