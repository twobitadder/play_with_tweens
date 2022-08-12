extends Resource
class_name StateMachine

signal state_entering(state_name)
signal state_exited(state_name)

var object = null
var state_map := {}
var states := []

func setup(attached_object) -> void:
	object = attached_object

func add_state(state : State) -> void:
	state_map[state.name] = state
	state_map[state.name].setup(object, self)

func update(delta : float) -> void:
	state_map[states.front()].update(delta)

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
