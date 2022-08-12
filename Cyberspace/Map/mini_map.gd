#warning-ignore-all:return_value_discarded
extends Node2D

signal room_entered(objects)

var player_grid_pos := Vector2.ZERO

func _ready() -> void:
	$PlayerMapPos.connect("move", self, "update_move")

func update_move(move) -> void:
	if !$ServerMap.test_move(player_grid_pos, player_grid_pos + move):
		return
	
	player_grid_pos += move
	$PlayerMapPos.move($ServerMap.get_loc(player_grid_pos))
	TimeKeeper.pass_time($ServerMap.traverse_cost)
	emit_signal("room_entered", $ServerMap.rooms[player_grid_pos].objects)
