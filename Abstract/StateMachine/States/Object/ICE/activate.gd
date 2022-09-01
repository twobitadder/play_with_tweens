extends State

var checkup_timer := 0.0

func setup(object, machine) -> void:
	.setup(object, machine)
	state_name = "activate"
	#attach its process to the player - doing whatever specific brand of harm it does

func process(delta : float) -> void:
	checkup_timer += delta
	if checkup_timer >= get_object().speed / 2.0 && PlayerInfo.grid_pos != WorldState.server.ice[get_object()]:
		emit_signal("done", "hunt")

func exit_state(new_state : String) -> bool:
	if new_state == "hunt":
		return true
	
	if get_object().is_suspicious:
		return false
	
	return true
