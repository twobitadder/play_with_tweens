extends Node2D

var player_grid_pos := Vector2.ZERO

func _ready() -> void:
	$PlayerMapPos.connect("move", self, "print_move")

func print_move(move) -> void:
	if !$ServerMap.test_move(player_grid_pos, player_grid_pos + move):
		return
	
	player_grid_pos += move
	$PlayerMapPos.move($ServerMap.get_loc(player_grid_pos))
