#warnings-disable
extends Resource
class_name State

signal done(next_state)

var state_name = "base--unusable"
var machine

func setup(_object, _machine) -> void:
	connect("done", _machine, "change_state")
	machine = _machine

func enter_state(prev_state) -> void:
	pass

func exit_state(new_state) -> bool:
	return true

func process(delta) -> void:
	pass

func get_object() -> Resource:
	return machine.get_object()
