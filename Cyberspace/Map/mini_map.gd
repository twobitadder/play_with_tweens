#warning-ignore-all:return_value_discarded
extends Node2D

signal room_entered(objects)


func _ready() -> void:
	$PlayerMapPos.connect("move", self, "update_move")

func update_move(move) -> void:
	if !$ServerMap.test_move(PlayerInfo.grid_pos, PlayerInfo.grid_pos + move):
		return
	
	PlayerInfo.grid_pos += move
	$PlayerMapPos.move($ServerMap.get_loc(PlayerInfo.grid_pos))
	TimeKeeper.pass_time($ServerMap.traverse_cost)
	emit_signal("room_entered", WorldState.rooms[PlayerInfo.grid_pos].objects)
