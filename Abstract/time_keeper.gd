extends Node

signal pass_time(timestep)

export var time_multiplier := 3.0

var time_left : float
var action_running := false

func _process(delta : float) -> void:
	if time_left > 0 || action_running:
		var time_passed := time_left
		time_left -= delta * time_multiplier
		time_left = max(time_left, 0.0)
		time_passed -= time_left
		emit_signal("pass_time", time_passed if !action_running else delta)

func pass_time(timestep : float) -> void:
	time_left += timestep
