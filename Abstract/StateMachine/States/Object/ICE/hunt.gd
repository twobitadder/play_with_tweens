extends State

var move_timer := 0.0

func setup(object, machine) -> void:
	.setup(object, machine)
	state_name = "hunt"

func enter_state(prev_state : String) -> void:
	if !machine.object.can_move:
		emit_signal("done", "return")

func process(delta : float) -> void:
	move_timer += delta
	if PlayerInfo.grid_pos == WorldState.server.ice[machine.object]:
		return
	
	if move_timer >= machine.object.speed:
		pass
		#set up an astar2d to get nodes on map
		#find path to player
		#move to next node

func exit_state(next_state : String) -> bool:
	if machine.object.is_suspicious:
		return false
	
	return true
