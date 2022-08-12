extends Node

signal pass_time(timestep)

export var time_multiplier := 1.0

var time_left : float

func _process(delta : float) -> void:
	if time_left > 0:
		var time_passed := time_left
		time_left -= delta * time_multiplier
		time_left = max(time_left, 0.0)
		time_passed -= time_left
		emit_signal("pass_time", time_passed)

func pass_time(timestep : float) -> void:
	time_left += timestep
