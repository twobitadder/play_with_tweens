extends Node
class_name State

signal done(next_state)

func setup(object, machine) -> void:
	connect("done", machine, "change_state")

func enter_state(prev_state) -> void:
	pass

func exit_state() -> bool:
	return true

func update(delta) -> void:
	pass
