extends Node2D

var room_template = preload("res://MapRoom.tscn")

export var max_size := 10
export var min_size := 5
export var max_iterations := 100

var rooms := []
var corridors := []

class RoomSorter:
	static func sort_rooms(a, b) -> bool:
		if a.steps < b.steps:
			return true
		elif a.steps == b.steps && a.type <= b.type:
			return true
		return false

func _ready() -> void:
	randomize()
	build_map()

func build_map() -> void:
	var heart := false
	var mind := false
	var server_size := randi() % (max_size - min_size) + min_size
	
	#first room must always be an entrance
	var first_room = room_template.instance()
	first_room.type = MapRoom.TYPE.ENTRANCE
	add_child(first_room)
	
	rooms.append(first_room)
	
	while rooms.size() < server_size:
		var blank_room = room_template.instance()
		var type_is_valid := false
		while !type_is_valid:
			blank_room.type = randi() % 6
			match blank_room.type:
				MapRoom.TYPE.ENTRANCE:
					type_is_valid = false
				MapRoom.TYPE.HEART:
					if !heart:
						heart = true
						type_is_valid = true
					else:
						type_is_valid = false
				MapRoom.TYPE.MIND:
					if !mind:
						mind = true
						type_is_valid = true
					else:
						type_is_valid = false
				_:
					type_is_valid = true
		add_child(blank_room)
		rooms.append(blank_room)
	
	var ordered := false
	var iterations := 0
	var parented := []
	var unparented := rooms.duplicate()
	#remove the entrance since it won't have a parent - added it to parented
	parented.append(unparented.pop_front())
	
	while !ordered && iterations < max_iterations:
		#shuffle both, parent first unparented room to last parented room
		unparented.shuffle()
		parented.shuffle()
		var next = unparented.pop_front()
		next.add_tree_parent(parented.back())
		parented.append(next)
		
		if unparented.size() == 0:
			ordered = true
		iterations += 1
	
	parented.sort_custom(RoomSorter, "sort_rooms")
	
	rooms = parented.duplicate()
	
	place_rooms()

func place_rooms() -> void:
	var y_iterator = 0
	var prev_step = 0
	var first_run = true
	for room in rooms:
		if room.steps == prev_step && !first_run:
			y_iterator +=1
		else:
			prev_step = room.steps
			y_iterator = 0
		room.position = Vector2(room.steps * 100, y_iterator * 100)
		if first_run:
			first_run = false
	setup_corridors()

func setup_corridors() -> void:
	for room in rooms:
		for child in room.children:
			corridors.append([room.position, child.position])
	
	update()

func _draw() -> void:
	for corridor in corridors:
		draw_line(corridor[0], corridor[1], Color.black, 3.0)
