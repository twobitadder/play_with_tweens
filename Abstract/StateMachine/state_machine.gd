extends Resource
class_name StateMachine

var idle_state = preload("res://Abstract/StateMachine/idle.gd")

signal state_entering(state_name)
signal state_exited(state_name)

var object = null
var state_map := {}
var states := []

func setup(attached_object, base_states : Array) -> void:
	object = attached_object
	for state in base_states:
		add_state(state)
	add_state(idle_state.new())
	states.append("idle")

func add_state(state : State) -> void:
	state.setup(object, self)
	state_map[state.state_name] = state

func process(delta : float) -> void:
	state_map[states.front()].process(delta)

func change_state(new_state : String) -> void:
	var valid = state_map[states.front()].exit_state()
	
	if (!valid):
		return
	
	var prev_state = states.front()
	
	if (new_state == states.front()):
		return
	
	emit_signal("state_exited", prev_state)
	
	if (new_state == "return"):
		states.pop_front()
	else:
		states.push_front(new_state)
	
	emit_signal("state_entering", states.front())
	state_map[states.front()].enter_state(prev_state)

func has_state(state : String) -> bool:
	return state_map.has(state)

func reset() -> void:
	states.clear()
